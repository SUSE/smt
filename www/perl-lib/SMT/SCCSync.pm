=head1 NAME

SMT::SCCSync - Module to sync from SCC

=head1 DESCRIPTION

Module to sync from SCC

=over 4

=cut

package SMT::SCCSync;
use strict;

use URI;
use SMT::SCCAPI;
use SMT::Utils;
use File::Temp;
use Date::Parse;
use SMT::Product;
use DBI qw(:sql_types);

use Data::Dumper;

# force autoflush on stdout write
$|++;

=item constructor

  SMT::SCCSync->new(...)

  * fromdir
  * todir
  * log
  * vblevel
  * dbh
  * useragent

=cut

sub new
{
    my $pkgname = shift;
    my %opt   = @_;

    my $self  = {};

    $self->{URI}   = undef;
    $self->{VBLEVEL} = 0;
    $self->{LOG}   = undef;
    $self->{USERAGENT}  = undef;
    $self->{CFG} = undef;

    $self->{MAX_REDIRECTS} = 5;

    $self->{AUTHUSER} = "";
    $self->{AUTHPASS} = "";

    $self->{MIGRATE} = 0;

    $self->{HTTPSTATUS} = 0;

    if (! defined $opt{fromdir} ) {
        $self->{SMTGUID} = SMT::Utils::getSMTGuid();
    }

    $self->{NCCEMAIL} = "";

    $self->{DBH} = undef;

    $self->{TEMPDIR} = File::Temp::tempdir("smt-XXXXXXXX", CLEANUP => 1, TMPDIR => 1);

    $self->{FROMDIR} = undef;
    $self->{TODIR}   = undef;

    $self->{ERRORS} = 0;

    # temporarily used variables
    $self->{REPO_DONE} = {};
    $self->{PROD_DONE} = {};
    $self->{PRODREPO} = {};
    $self->{EXTS} = {};
    $self->{MIGS} = {};
    $self->{TARGET_DONE} = {};
    $self->{NUHOSTS} = ['nu.novell.com', 'updates.suse.com'];
    $self->{LOCALHOST} = "";
    $self->{LOCALSCHEME} = "https";

    $self->{CACHE} = {};

    if(exists $opt{vblevel} && $opt{vblevel})
    {
        $self->{VBLEVEL} = $opt{vblevel};
    }

    if(exists $opt{cfg} && $opt{cfg})
    {
        $self->{CFG} = $opt{cfg};
    }
    else
    {
        $self->{CFG} = SMT::Utils::getSMTConfig();
    }

    if(exists $opt{log} && $opt{log})
    {
        $self->{LOG} = $opt{log};
    }
    else
    {
        $self->{LOG} = SMT::Utils::openLog();
    }

    if(exists $opt{fromdir} && defined $opt{fromdir} && -d $opt{fromdir})
    {
        $self->{FROMDIR} = $opt{fromdir};
    }
    elsif(exists $opt{todir} && defined $opt{todir} && -d $opt{todir})
    {
        $self->{TODIR} = $opt{todir};
    }

    if(exists $opt{dbh} && defined $opt{dbh} && $opt{dbh})
    {
        $self->{DBH} = $opt{dbh};
    }
    elsif(!defined $self->{TODIR} || $self->{TODIR} eq "")
    {
        # init the database only if we do not sync to a directory
        $self->{DBH} = SMT::Utils::db_connect();
    }

    if(exists $opt{nccemail} && defined $opt{nccemail})
    {
        $self->{NCCEMAIL} = $opt{nccemail};
    }

    if(exists $opt{useragent} && defined $opt{useragent} && $opt{useragent})
    {
        $self->{USERAGENT} = $opt{useragent};
    }
    else
    {
        $self->{USERAGENT} = SMT::Utils::createUserAgent(log => $self->{LOG}, vblevel => $self->{VBLEVEL});
        $self->{USERAGENT}->protocols_allowed( [ 'https'] );
    }

    my ($ruri, $user, $pass) = SMT::Utils::getLocalRegInfos();

    $self->{URI}      = $ruri;
    $self->{AUTHUSER} = $user;
    $self->{AUTHPASS} = $pass;

    $self->{API} = SMT::SCCAPI->new(vblevel => $self->{VBLEVEL},
                                    log     => $self->{LOG},
                                    useragent => $self->{USERAGENT},
                                    url => $self->{URI},
                                    authuser => $self->{AUTHUSER},
                                    authpass => $self->{AUTHPASS},
                                    ident => $self->{SMTGUID}
                                   );

    my $regsharing = SMT::Utils::hasRegSharing();
    if (! defined $regsharing) {
        my $msg = 'Could not read SMT configuration file';
        printLog($self->{LOG}, $self->vblevel(), LOG_WARN, __($msg));
        $regsharing = 0;
    }
    if ($regsharing && ! $self->{REGSHARING}) {
        eval
        {
            require 'SMT/RegistrationSharing.pm';
            $self->{REGSHARING} = 1;
        };
        if ($@)
        {
            my $msg = 'Failed to load registration sharing module '
              . '"SMT/RegistrationSharing.pm"'
              . "\n$@";
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, __($msg));
        }
    }

    bless($self);

    return $self;
}

=item vblevel([level])

Set or get the verbose level.

=cut

sub vblevel
{
    my $self = shift;
    if (@_) { $self->{VBLEVEL} = shift }
    return $self->{VBLEVEL};
}

=item migrate(1/0)

Enable or disable migration mode. The migration mode
convert NCC data existing in DB into SCC data.

=cut

sub migrate
{
    my $self = shift;
    if (@_) { $self->{MIGRATE} = shift }
    return $self->{MIGRATE};
}

=item canMigrate

Test if a migration is possible.
Return:
0 if the migration is possible.
1 internal server error
3 migration not possible because clients exists which uses products not provided by NCC
4 migration not possible because clients exists which uses repositories not provided by NCC


=cut

sub canMigrate
{
    my $self = shift;
    my $input = $self->_getInput("organizations_products_unscoped");
    my $errors = 0;

    if (! $input)
    {
        printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR,
                 __("Failed to get product information from SCC. Migration is not possible."));
        return 1;
    }

    #
    # new registration server need to support all locally used
    # products. SCC will import all products of a product_class
    #
    my $statement = "SELECT DISTINCT p.PRODUCT_CLASS
                     FROM Products p, Registration r
                     WHERE r.PRODUCTID=p.ID";
    my $classes = $self->{DBH}->selectall_arrayref($statement, {Slice => {}});
    foreach my $c (@{$classes})
    {
        my $found = 0;
        foreach my $product (@$input)
        {
            if ( $c->{PRODUCT_CLASS} eq ($product->{product_class}||'') )
            {
                $found = 1;
                last;
            }
        }
        if ( ! $found )
        {
            printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO1,
                     sprintf("'%s' not found in registration server. Migration not possible.",
                             $c->{PRODUCT_CLASS}), 0, 1);
            printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO2,
                     sprintf("'%s' not found in registration server. Migration not possible.",
                             $c->{PRODUCT_CLASS}), 1, 0);
            $errors++;
        }
    }

    if ($errors)
    {
        printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR,
                 __("Products found which are not supported by SCC. Migration is not possible.")."\n".
                 __("Please check the logfile for more information."));
        return 3;
    }

    $input = $self->_getInput("organizations_repositories");

    if (! $input)
    {
        printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR,
                 __("Failed to get repository information from SCC. Migration is not possible."));
        return 1;
    }
    #
    # All locally mirrored NCC repos need to be accessible via
    # the new registration server
    #
    $statement = "SELECT ID, NAME, TARGET FROM Catalogs
                   WHERE DOMIRROR='Y'
                     AND MIRRORABLE='Y'
                     AND SRC = 'N'";
    my $catalogs = $self->{DBH}->selectall_hashref($statement, 'ID');
    foreach my $needed_cid (keys %{$catalogs})
    {
        my $found = 0;
        foreach my $repo (@$input)
        {
            if ($catalogs->{$needed_cid}->{NAME} eq $repo->{name} &&
                ($catalogs->{$needed_cid}->{TARGET}||'') eq ($repo->{distro_target}||''))
            {
                $found = 1;
                last;
            }
        }
        if ( ! $found )
        {
            printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO1,
                     sprintf("Repository '%s-%s' not found in registration server. Migration not possible.",
                             $catalogs->{$needed_cid}->{NAME},
                             $catalogs->{$needed_cid}->{TARGET}), 0, 1);
            printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO2,
                     sprintf("Repository '%s-%s' not found in registration server. Migration not possible.",
                             $catalogs->{$needed_cid}->{NAME},
                             $catalogs->{$needed_cid}->{TARGET}), 1, 0);
            $errors++;
        }
    }
    if ($errors)
    {
        printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR,
                 __("Used repositories found which are not supported by SCC. Migration is not possible.")."\n".
                 __("Please check the logfile for more information."));
        return 4;
    }

    return 0;
}

=item products

Update Products, Repository and and the relations between these two.
Return number of errors.

=cut

sub products
{
    my $self = shift;
    my $name = "organizations_products_unscoped";
    my $input = $self->_getInput($name);

    if (! $input)
    {
        return 1;
    }
    if(defined $self->{TODIR})
    {
        open( FH, '>', $self->{TODIR}."/$name.json") or do
        {
            printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR, "Cannot open file: $!");
            return 1;
        };
        my $json_text = JSON::encode_json($input);
        print FH "$json_text";
        close FH;
        return 0;
    }
    else
    {
        my $ret = $self->_updateProductData($input);
        return $ret;
    }
}

=item subscriptions

Update subscriptions and connect them to the registered clients.
Return number of errors.

=cut

sub subscriptions
{
    my $self = shift;
    my $name = "organizations_subscriptions";
    my $input = $self->_getInput($name);

    if (! $input)
    {
        return 1;
    }
    if(defined $self->{TODIR})
    {
        open( FH, '>', $self->{TODIR}."/$name.json") or do
        {
            printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR, "Cannot open file: $!");
            return 1;
        };
        my $json_text = JSON::encode_json($input);
        print FH "$json_text";
        close FH;
        return 0;
    }
    else
    {
        my $ret = $self->_updateSubscriptionData($input);
        return $ret;
    }
}

=item orders

Write orders if option TODIR is given.
Return number of errors.

=cut

sub orders
{
    my $self = shift;
    my $name = "organizations_orders";

    if(defined $self->{TODIR})
    {
        my $input = $self->_getInput($name);
        if (! $input)
        {
            return 1;
        }
        open( FH, '>', $self->{TODIR}."/$name.json") or do
        {
            printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR, "Cannot open file: $!");
            return 1;
        };
        my $json_text = JSON::encode_json($input);
        print FH "$json_text";
        close FH;
        return 0;
    }
    else
    {
	printLog($self->{LOG}, $self->{VBLEVEL}, LOG_INFO1, "Downloading Orders skipped");
        return 0;
    }
}

sub finalize_mirrorable_repos
{
    my $self = shift;
    my $name = "organizations_repositories";
    my $input = $self->_getInput($name);

    if (! $input)
    {
        return 1;
    }

    if(defined $self->{TODIR})
    {
        open( FH, '>', $self->{TODIR}."/$name.json") or do
        {
            printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR, "Cannot open file: $!");
            return 1;
        };
        my $json_text = JSON::encode_json($input);
        print FH "$json_text";
        close FH;
        return 0;
    }
    else
    {
        my $ret = $self->_finalizeMirrorableRepos($input);
        return $ret;
    }
}

sub register_systems
{
    my $self = shift;
    my $sleeptime = shift || 1;
    my $allguids = $self->{DBH}->selectcol_arrayref("SELECT DISTINCT GUID from Registration WHERE (REGDATE > NCCREGDATE || NCCREGDATE IS NULL) && NCCREGERROR=0");

    if(@{$allguids} > 0)
    {
        # we have something to register, check for random sleep value
        sleep(int($sleeptime));

        printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf("Register %d new clients.", ($#{$allguids}+1) ) );
    }
    else
    {
        # nothing to register -- success
        return 0;
    }

    my $exitcode = 0;
    foreach my $guid (@$allguids)
    {
        my $products = $self->{DBH}->selectall_arrayref(sprintf("select p.ID, p.PRODUCTDATAID, p.PRODUCT, p.VERSION, p.REL, p.ARCH
                                                                   from Products p, Registration r
                                                                  where r.GUID=%s
                                                                    and r.PRODUCTID=p.ID", $self->{DBH}->quote($guid)),
                                                        {Slice => {}});

        my $regdata =  $self->{DBH}->selectall_arrayref(sprintf("select KEYNAME, VALUE from MachineData where GUID=%s",
                                                                $self->{DBH}->quote($guid)), {Slice => {}});
        my $data = $self->{DBH}->selectrow_hashref(sprintf("SELECT GUID as login, SECRET as password, HOSTNAME as hostname
                                                            FROM Clients WHERE GUID=%s", $self->{DBH}->quote($guid)));
        ($data->{products}, $data->{regcodes}) = $self->_products_from_db($products, $regdata);
        my $machinedata = $self->_machinedata_from_db($regdata);
        if(exists $machinedata->{hwinfo} && $machinedata->{hwinfo})
        {
            $data->{hwinfo} = $machinedata->{hwinfo};
        }
        my $result = $self->{API}->org_systems_set(body => $data);
        if(! $self->{API}->is_error($result))
        {
            my $sth = $self->{DBH}->prepare(sprintf("UPDATE Registration SET NCCREGDATE=?, NCCREGERROR=0 WHERE GUID=%s",
                                                    $self->{DBH}->quote($guid)));
            $sth->bind_param(1, SMT::Utils::getDBTimestamp(), SQL_TIMESTAMP);
            $sth->execute;
            my $statement = sprintf("UPDATE Clients SET systemid=%s WHERE GUID=%s",
                                    $self->{DBH}->quote($result->{id}),
                                    $self->{DBH}->quote($guid));
            $self->{DBH}->do($statement);
            printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf(__("Registration success: '%s'."), $guid));
        }
        else
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
                     sprintf("Registration of %s failed: %s", $guid, $result->{error}));
            $self->{DBH}->do(sprintf("UPDATE Registration SET NCCREGERROR=1 WHERE GUID=%s",
                                     $self->{DBH}->quote($guid)));
            $exitcode = 1;
        }
    }
    return $exitcode;
}

sub delete_systems
{
    my $self = shift;
    my @guids = @_;
    my $exitcode = 0;

    my $allowRegister = $self->{CFG}->val("LOCAL", "forwardRegistration", 'true');
    foreach my $guid (@guids)
    {
        my $data = $self->{DBH}->selectrow_arrayref(
            sprintf("SELECT GUID from Registration where NCCREGDATE IS NOT NULL and GUID=%s",
                    $self->{DBH}->quote($guid)));
        my $id = $self->{DBH}->selectrow_arrayref(
            sprintf("SELECT systemid from Clients where GUID=%s",
                    $self->{DBH}->quote($guid)));

        $self->_deleteRegistrationLocal($guid);
        if ($self->{REGSHARING})
        {
            SMT::RegistrationSharing::deleteSiblingRegistration(
                                                        $guid,
                                                        $self->{LOG}
            );
        }
        if(!($data->[0] && $data->[0] eq $guid))
        {
            # this GUID was never registered at NCC
            # no need to delete it there
            next;
        }
        if($allowRegister ne "true")
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_WARN, "Forward registration is disabled. '$guid' deleted only locally.");
            next;
        }
        if(!$id->[0]) {
            printLog($self->{LOG}, $self->vblevel(), LOG_WARN, "Systemid for '$guid' not available. Client deleted only locally.");
            $exitcode = 1;
            next;
        }
        my $result = $self->{API}->org_systems_delete($id->[0]);
        if($self->{API}->is_error($result))
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Failed to delete '$guid' from SCC: ". $result->{error});
            $exitcode = 1;
        }
        else
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf("Successfully delete registration from SCC: %s", $guid));
        }
    }
    return $exitcode;
}

sub cleanup_db
{
    my $self = shift;
    return 0 if (not $self->migrate());

    eval
    {
        my $res = $self->{DBH}->do("DELETE FROM Products WHERE SRC='N'");
        $res = $self->{DBH}->do("DELETE FROM Catalogs WHERE SRC='N'");
        $res = $self->{DBH}->do("DELETE FROM ProductCatalogs WHERE SRC='N'");
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        return 1;
    }
    return 0;
}
###############################################################################
###############################################################################
###############################################################################
###############################################################################

#
# read json file from "FROMDIR" or call API to fetch from SCC.
# Return the decoded JSON structure or undef in case of an error.
#
# This method cache the API result in memory. Every API will be called
# only once.
#
sub _getInput
{
    my $self = shift;
    my $what = shift;
    my $input = undef;
    my $func = undef;

    if (exists $self->{CACHE}->{$what})
    {
        return $self->{CACHE}->{$what};
    }

    if($what eq "organizations_products_unscoped")
    {
        $func = sub{$self->{API}->org_products()};
    }
    elsif($what eq "organizations_subscriptions")
    {
        $func = sub{$self->{API}->org_subscriptions()};
    }
    elsif($what eq "organizations_orders")
    {
        $func = sub{$self->{API}->org_orders()};
    }
    elsif($what eq "organizations_repositories")
    {
        $func = sub{$self->{API}->org_repos()};
    }
    else
    {
        return undef;
    }

    if($self->{FROMDIR} && -d $self->{FROMDIR})
    {
        open( FH, '<', $self->{FROMDIR}."/$what.json" ) and do
        {
            my $json_text   = <FH>;
            $input = JSON::decode_json( $json_text );
            close FH;
        };
    }
    else
    {
        $input = &$func();
    }
    if ($self->{API}->is_error($input))
    {
        return undef;
    }
    $self->{CACHE}->{$what} = $input;

    return $input;
}

sub _updateProducts
{
    my $self = shift;
    my $product = shift;

    my $statement = "";
    my $ret = 0;
    my $retprd = 0;
    my $paramlist =<<EOP
<paramlist xmlns="http://www.novell.com/xml/center/regsvc-1_0"
lang="">
  <guid description="" class="mandatory" />
  <param id="secret" description="" command="zmd-secret"
  class="mandatory" />
  <host description="" />
  <product description="" class="mandatory" />
  <param id="ostarget" description="" command="zmd-ostarget"
  class="mandatory" />
  <param id="ostarget-bak" description="" command="lsb_release -sd"
  class="mandatory" />
  <param id="processor" description="" command="uname -p" />
  <param id="platform" description="" command="uname -i" />
  <param id="hostname" description="" command="uname -n" />
  <param id="cpu" description="" command="hwinfo --cpu" />
  <param id="memory" description="" command="hwinfo --memory" />
</paramlist>
EOP
;
    my $needinfo =<<EON
<?xml version="1.0" encoding="utf-8"?>
<needinfo xmlns="http://www.novell.com/xml/center/regsvc-1_0"
lang="" href="">
  <guid description="" class="mandatory" />
  <param id="secret" description="" command="zmd-secret"
  class="mandatory" />
  <host description="" />
  <product description="" class="mandatory" />
  <param id="ostarget" description="" command="zmd-ostarget"
  class="mandatory" />
  <param id="ostarget-bak" description="" command="lsb_release -sd"
  class="mandatory" />
  <param id="sysident" description="">
    <param id="processor" description="" command="uname -p" />
    <param id="platform" description="" command="uname -i" />
    <param id="hostname" description="" command="uname -n" />
  </param>
  <param id="hw_inventory" description="">
    <param id="cpu" description="" command="hwinfo --cpu" />
    <param id="memory" description="" command="hwinfo --memory" />
  </param>
  <privacy url="http://www.novell.com/company/policies/privacy/textonly.html"
  description="" class="informative" />
</needinfo>
EON
;
    my $service =<<EOS
<service xmlns="http://www.novell.com/xml/center/regsvc-1_0"
id="\${mirror:id}" description="\${mirror:name}" type="\${mirror:type}">
  <param id="url">\${mirror:url}</param>
  <group-catalogs/>
</service>
EOS
;

    # we inserted/update this product already in this run
    # so let's skip it
    return 0 if(exists $self->{PROD_DONE}->{$product->{id}});

    if ($product->{eula_url})
    {
        my $eulaUrl = URI->new($product->{eula_url});
        $eulaUrl->path(SMT::Utils::cleanPath("repo", $eulaUrl->path()));
        $eulaUrl->fragment(undef);
        $eulaUrl->query(undef);
        $eulaUrl->host($self->{LOCALHOST});
        $eulaUrl->scheme($self->{LOCALSCHEME});
        $product->{eula_url} = $eulaUrl->as_string();
    }

    if (! $self->migrate() &&
        (my $pid = SMT::Utils::lookupProductIdByDataId($self->{DBH}, $product->{id}, 'S', $self->{LOG}, $self->vblevel)))
    {
        $statement = sprintf("UPDATE Products
                                 SET PRODUCT = %s, VERSION = %s,
                                     REL = %s, ARCH = %s,
                                     PRODUCTLOWER = %s, VERSIONLOWER = %s,
                                     RELLOWER = %s, ARCHLOWER = %s,
                                     FRIENDLY = %s, PRODUCT_LIST = %s,
                                     PRODUCT_CLASS = %s, PRODUCTDATAID = %s,
                                     CPE = %s, DESCRIPTION = %s, EULA_URL = %s,
                                     FORMER_IDENTIFIER = %s, PRODUCT_TYPE = %s,
                                     SHORTNAME = %s, RELEASE_STAGE = %s
                               WHERE ID = %s",
                             $self->{DBH}->quote($product->{identifier}),
                             $self->{DBH}->quote($product->{version}),
                             $self->{DBH}->quote($product->{release_type}),
                             $self->{DBH}->quote($product->{arch}),
                             $self->{DBH}->quote(lc($product->{identifier})),
                             $self->{DBH}->quote(($product->{version}?lc($product->{version}):undef)),
                             $self->{DBH}->quote(($product->{release_type}?lc($product->{release_type}):undef)),
                             $self->{DBH}->quote(($product->{arch}?lc($product->{arch}):undef)),
                             $self->{DBH}->quote($product->{friendly_name}),
                             $self->{DBH}->quote('Y'), # SCC give all products back - all are listed.
                             $self->{DBH}->quote($product->{product_class}),
                             $self->{DBH}->quote($product->{id}),
                             $self->{DBH}->quote($product->{cpe}),
                             $self->{DBH}->quote($product->{description}),
                             $self->{DBH}->quote($product->{eula_url}),
                             $self->{DBH}->quote($product->{former_identifier}),
                             $self->{DBH}->quote($product->{product_type}),
                             $self->{DBH}->quote((! defined $product->{shortname})?'':$product->{shortname}),
                             $self->{DBH}->quote((! $product->{release_stage})?'':$product->{release_stage}),
                             $self->{DBH}->quote($pid)
        );
    }
    elsif ($self->migrate() && ($pid = SMT::Utils::lookupProductIdByName($self->{DBH}, $product->{identifier},
                                                                         $product->{version},
                                                                         $product->{release_type},
                                                                         $product->{arch},
                                                                         $self->{LOG}, $self->vblevel)))
    {
        $self->_migrateMachineData($pid, $product->{id});
        $statement = sprintf("UPDATE Products
                                 SET PRODUCT = %s, VERSION = %s,
                                     REL = %s, ARCH = %s,
                                     PRODUCTLOWER = %s, VERSIONLOWER = %s,
                                     RELLOWER = %s, ARCHLOWER = %s,
                                     FRIENDLY = %s, PRODUCT_LIST = %s,
                                     PRODUCT_CLASS = %s, PRODUCTDATAID = %s,
                                     CPE = %s, DESCRIPTION = %s, EULA_URL = %s,
                                     FORMER_IDENTIFIER = %s, PRODUCT_TYPE = %s,
                                     SHORTNAME = %s, RELEASE_STAGE = %s, SRC = 'S'
                               WHERE ID = %s",
                             $self->{DBH}->quote($product->{identifier}),
                             $self->{DBH}->quote($product->{version}),
                             $self->{DBH}->quote($product->{release_type}),
                             $self->{DBH}->quote($product->{arch}),
                             $self->{DBH}->quote(lc($product->{identifier})),
                             $self->{DBH}->quote(($product->{version}?lc($product->{version}):undef)),
                             $self->{DBH}->quote(($product->{release_type}?lc($product->{release_type}):undef)),
                             $self->{DBH}->quote(($product->{arch}?lc($product->{arch}):undef)),
                             $self->{DBH}->quote($product->{friendly_name}),
                             $self->{DBH}->quote('Y'), # SCC give all products back - all are listed.
                             $self->{DBH}->quote($product->{product_class}),
                             $self->{DBH}->quote($product->{id}),
                             $self->{DBH}->quote($product->{cpe}),
                             $self->{DBH}->quote($product->{description}),
                             $self->{DBH}->quote($product->{eula_url}),
                             $self->{DBH}->quote($product->{former_identifier}),
                             $self->{DBH}->quote($product->{product_type}),
                             $self->{DBH}->quote((! defined $product->{shortname})?'':$product->{shortname}),
                             $self->{DBH}->quote((! $product->{release_stage})?'':$product->{release_stage}),
                             $self->{DBH}->quote($pid)
        );
    }
    else
    {
        $statement = sprintf("INSERT INTO Products (PRODUCT, VERSION, REL, ARCH,
                              PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER,
                              PARAMLIST, NEEDINFO, SERVICE, FRIENDLY, PRODUCT_LIST,
                              PRODUCT_CLASS, CPE, DESCRIPTION, EULA_URL, PRODUCTDATAID,
                              FORMER_IDENTIFIER, PRODUCT_TYPE, SHORTNAME, RELEASE_STAGE, SRC)
                              VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'S')",
                             $self->{DBH}->quote($product->{identifier}),
                             $self->{DBH}->quote($product->{version}),
                             $self->{DBH}->quote($product->{release_type}),
                             $self->{DBH}->quote($product->{arch}),
                             $self->{DBH}->quote(lc($product->{identifier})),
                             $self->{DBH}->quote(($product->{version}?lc($product->{version}):undef)),
                             $self->{DBH}->quote(($product->{release_type}?lc($product->{release_type}):undef)),
                             $self->{DBH}->quote(($product->{arch}?lc($product->{arch}):undef)),
                             $self->{DBH}->quote($paramlist),
                             $self->{DBH}->quote($needinfo),
                             $self->{DBH}->quote($service),
                             $self->{DBH}->quote($product->{friendly_name}),
                             $self->{DBH}->quote('Y'),
                             $self->{DBH}->quote($product->{product_class}),
                             $self->{DBH}->quote($product->{cpe}),
                             $self->{DBH}->quote($product->{description}),
                             $self->{DBH}->quote($product->{eula_url}),
                             $self->{DBH}->quote($product->{id}),
                             $self->{DBH}->quote($product->{former_identifier}),
                             $self->{DBH}->quote($product->{product_type}),
                             $self->{DBH}->quote((! defined $product->{shortname})?'':$product->{shortname}),
                             $self->{DBH}->quote((! $product->{release_stage})?'':$product->{release_stage})
        );
    }
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
    eval {
        $self->{DBH}->do($statement);
        $self->{PROD_DONE}->{$product->{id}} = 1;
    };
    if($@)
    {
        if( $@ =~ /Duplicate entry/i )
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, "Duplicate entry found, executing auto migration.");
            if ($self->_mergeProducts($product) == 0)
            {
                $retprd = $self->_updateProducts($product);
            }
            else
            {
                $retprd = 1;
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Product merge failed.");
            }
        }
        else
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
            $retprd = 1;
        }
    }

    foreach my $repo (@{$product->{repositories}})
    {
        my $retcat = $self->_updateRepositories($repo);
        $ret += $retcat;

        # if either product or catalogs could not be added,
        # we will fail to add the relation.
        next if ( $retprd || $retcat);
        $self->_collectProductCatalogs($product, $repo);
    }
    $ret += $retprd;

    foreach my $ext (@{$product->{extensions}})
    {
        $ret += $self->_updateProducts($ext);
        $self->_collectExtensions($product->{id}, $ext->{id});
    }
    if (exists $product->{predecessor_ids})
    {
        $self->_collectMigrations($product->{id}, $product->{predecessor_ids});
    }

    return $ret;
}

sub _mergeProducts
{
    my $self = shift;
    my $product = shift || return 1;

    my $otherdataid = SMT::Utils::lookupProductDataIdByName($self->{DBH}, $product->{identifier},
                                                            $product->{version},
                                                            $product->{release_type},
                                                            $product->{arch},
                                                            $self->{LOG}, $self->vblevel);
    if ($otherdataid eq $product->{id})
    {
        # if this happens we should not have a problem.
        # So why get we here ?
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
                 sprintf("Cannot merge: %s -> %s: %s %s %s %s", $otherdataid,
                         $product->{id}, $product->{identifier},
                         $product->{version}, $product->{release_type},
                         $product->{arch}));
        return 1;
    }
    my $correctpdid = SMT::Utils::lookupProductIdByDataId($self->{DBH},
                                                          $product->{id}, 'S',
                                                          $self->{LOG}, $self->vblevel);
    my $otherpdid = SMT::Utils::lookupProductIdByDataId($self->{DBH},
                                                      $otherdataid, undef,
                                                      $self->{LOG}, $self->vblevel);
    return 1 if ! $otherpdid;

    my $statement = sprintf("update Registration
                                set PRODUCTID = %s
                              where PRODUCTID = %s",
                            $self->{DBH}->quote($correctpdid),
                            $self->{DBH}->quote($otherpdid));
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
    eval {
        $self->{DBH}->do($statement);
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        return 1;
    }

    $statement = sprintf("delete from Products
                           where ID = %s",
                         $self->{DBH}->quote($otherpdid));
    eval {
        $self->{DBH}->do($statement);
    };
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        return 1;
    }
    return 0;
}

sub _collectExtensions
{
    my $self  = shift || return;
    my $prdid = shift || return;
    my $extid = shift || return;

    $self->{EXTS}->{"$prdid-$extid"} = {productid => $prdid, extensionid => $extid};
}

sub _updateExtensions
{
    my $self  = shift || return 1;
    my $err = 0;
    my $href = {};

    my $sql = "select PRODUCTID, EXTENSIONID from ProductExtensions where SRC = 'S'";
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $sql");
    eval {
        my $ref = $self->{DBH}->selectall_arrayref($sql, {Slice => {}});

        foreach my $v (@{$ref})
        {
            $href->{$v->{PRODUCTID}."-".$v->{EXTENSIONID}} = $v;
        }
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        $err += 1;
    }

    foreach my $key (keys %{$self->{EXTS}})
    {
        my $prdid = SMT::Utils::lookupProductIdByDataId($self->{DBH}, $self->{EXTS}->{$key}->{productid}, 'S',
                                                        $self->{LOG}, $self->vblevel());
        my $extid = SMT::Utils::lookupProductIdByDataId($self->{DBH}, $self->{EXTS}->{$key}->{extensionid}, 'S',
                                                              $self->{LOG}, $self->vblevel());

        if (exists $href->{$prdid."-".$extid})
        {
            delete $href->{$prdid."-".$extid};
            next;
        }
        else
        {
            if(!$prdid)
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Productid not found for: ".$self->{EXTS}->{$key}->{productid});
                $err += 1;
                next;
            }
            if(!$extid)
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Extensionid not found for: ".$self->{EXTS}->{$key}->{extensionid});
                $err += 1;
                next;
            }
            my $sql = sprintf("INSERT INTO ProductExtensions VALUES ( %s, %s, 'S')",
                              $self->{DBH}->quote($prdid),
                              $self->{DBH}->quote($extid));
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $sql");
            eval {
                $self->{DBH}->do($sql);
            };
            if($@)
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
                return 1;
            }
        }
    }
    # remove obsolete entries
    foreach my $key (keys %{$href})
    {
        $sql = sprintf("DELETE FROM ProductExtensions WHERE PRODUCTID = %s AND EXTENSIONID = %s",
                       $self->{DBH}->quote($href->{$key}->{PRODUCTID}),
                       $self->{DBH}->quote($href->{$key}->{EXTENSIONID}));
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $sql");
        eval {
            $self->{DBH}->do($sql);
        };
        if($@)
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
            $err += 1;
        }
    }
    return 0;
}

sub _collectMigrations
{
    my $self    = shift || return 1;
    my $prdid   = shift || return 1;
    my $predIds = shift || return 1;

    foreach my $predecessor (@$predIds)
    {
        $self->{MIGS}->{"$prdid-$predecessor"} = {pdid => $prdid, predecessorid => $predecessor};
    }
}

sub _updateMigrations
{
    my $self    = shift || return 1;
    my $err = 0;
    my $href = {};

    my $sql = "select SRCPDID, TGTPDID from ProductMigrations where SRC = 'S'";
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $sql");
    eval {
        my $ref = $self->{DBH}->selectall_arrayref($sql, {Slice => {}});

        foreach my $v (@{$ref})
        {
            $href->{$v->{TGTPDID}."-".$v->{SRCPDID}} = $v;
        }
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        $err += 1;
    }

    foreach my $key (keys %{$self->{MIGS}})
    {
        my $prdid = SMT::Utils::lookupProductIdByDataId($self->{DBH}, $self->{MIGS}->{$key}->{pdid}, 'S',
                                                        $self->{LOG}, $self->vblevel());
        my $predecessor = SMT::Utils::lookupProductIdByDataId($self->{DBH}, $self->{MIGS}->{$key}->{predecessorid}, 'S',
                                                              $self->{LOG}, $self->vblevel());

        if (exists $href->{$prdid."-".$predecessor})
        {
            delete $href->{$prdid."-".$predecessor};
            next;
        }
        else
        {
            $sql = sprintf("INSERT INTO ProductMigrations VALUES (%s, %s, 'S')",
                           $self->{DBH}->quote($predecessor),
                           $self->{DBH}->quote($prdid));
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $sql");
            eval {
                $self->{DBH}->do($sql);
            };
            if($@)
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
                $err += 1;
            }
        }
    }
    # remove obsolete entries
    foreach my $key (keys %{$href})
    {
        $sql = sprintf("DELETE FROM ProductMigrations WHERE TGTPDID = %s AND SRCPDID = %s",
                       $self->{DBH}->quote($href->{$key}->{TGTPDID}),
                       $self->{DBH}->quote($href->{$key}->{SRCPDID}));
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $sql");
        eval {
            $self->{DBH}->do($sql);
        };
        if($@)
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
            $err += 1;
        }
    }
    return $err;
}

sub _updateRepositories
{
    my $self = shift;
    my $repo = shift;
    my $statement = "";
    my $localpath = "";
    my $catalogtype = "";
    # we inserted/update this repo already in this run
    # so let's skip it
    return 0 if(exists $self->{REPO_DONE}->{$repo->{id}});

    my $exthost = URI->new($repo->{url});
    $localpath = $exthost->path();
    $exthost->path(undef);
    $exthost->fragment(undef);
    $exthost->query(undef);

    if( grep {$_ eq $exthost->host} @{$self->{NUHOSTS}} )
    {
        $localpath =~ s/^\///;
        if($localpath =~ /^repo\//)
        {
            $localpath =~ s/^repo\///;
        }
        $catalogtype = 'nu';
        if (!$repo->{distro_target})
        {
            # catalogs of type 'nu' must have a target.
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
                sprintf("ERROR: NU repository '%s' without distro_target reported by SUSE Customer Center. Skipping",
                        $repo->{name}));
            return 1;
        }
    }
    else
    {
        # we need to check if this is ATI or NVidia SP1 repos and have to rename it

        if($repo->{name} eq "ATI-Drivers" && $repo->{url} =~ /sle10sp1/)
        {
            $repo->{name} = $repo->{name}."-SP1";
        }
        elsif($repo->{name} eq "nVidia-Drivers" && $repo->{url} =~ /sle10sp1/)
        {
            $repo->{name} = $repo->{name}."-SP1";
        }
        $localpath = "RPMMD/".$repo->{name};
        $catalogtype = 'zypp';
    }

    if (! $self->migrate() &&
        (my $cid = SMT::Utils::lookupCatalogIdByDataId($self->{DBH}, $repo->{id}, 'S', $self->{LOG}, $self->vblevel)))
    {
        $statement = sprintf("UPDATE Catalogs
                                 SET NAME = %s, DESCRIPTION = %s,
                                     TARGET = %s, LOCALPATH = %s,
                                     EXTHOST = %s, EXTURL = %s,
                                     CATALOGTYPE = %s, CATALOGID = %s,
                                     AUTOREFRESH = %s
                               WHERE ID = %s",
                             $self->{DBH}->quote($repo->{name}),
                             $self->{DBH}->quote($repo->{description}),
                             $self->{DBH}->quote($repo->{distro_target}),
                             $self->{DBH}->quote($localpath),
                             $self->{DBH}->quote($exthost),
                             $self->{DBH}->quote($repo->{url}),
                             $self->{DBH}->quote($catalogtype),
                             $self->{DBH}->quote($repo->{id}),
                             $self->{DBH}->quote(($repo->{autorefresh}?'Y':'N')),
                             $self->{DBH}->quote($cid)
        );
    }
    elsif ($self->migrate() &&
           ($cid = SMT::Utils::lookupCatalogIdByName($self->{DBH}, $repo->{name}, $repo->{distro_target}, $self->{LOG}, $self->vblevel)))
    {
        $statement = sprintf("UPDATE Catalogs
                                 SET NAME = %s, DESCRIPTION = %s,
                                     TARGET = %s, LOCALPATH = %s,
                                     EXTHOST = %s, EXTURL = %s,
                                     CATALOGTYPE = %s, CATALOGID = %s,
                                     AUTOREFRESH = %s,
                                     SRC = 'S'
                               WHERE ID = %s",
                             $self->{DBH}->quote($repo->{name}),
                             $self->{DBH}->quote($repo->{description}),
                             $self->{DBH}->quote($repo->{distro_target}),
                             $self->{DBH}->quote($localpath),
                             $self->{DBH}->quote($exthost),
                             $self->{DBH}->quote($repo->{url}),
                             $self->{DBH}->quote($catalogtype),
                             $self->{DBH}->quote($repo->{id}),
                             $self->{DBH}->quote(($repo->{autorefresh}?'Y':'N')),
                             $self->{DBH}->quote($cid)
        );
    }
    else
    {
        $statement = sprintf("INSERT INTO Catalogs (NAME, DESCRIPTION, TARGET, LOCALPATH,
                              EXTHOST, EXTURL, CATALOGTYPE, CATALOGID, AUTOREFRESH, SRC)
                              VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, 'S')",
                             $self->{DBH}->quote($repo->{name}),
                             $self->{DBH}->quote($repo->{description}),
                             $self->{DBH}->quote($repo->{distro_target}),
                             $self->{DBH}->quote($localpath),
                             $self->{DBH}->quote($exthost),
                             $self->{DBH}->quote($repo->{url}),
                             $self->{DBH}->quote($catalogtype),
                             $self->{DBH}->quote($repo->{id}),
                             $self->{DBH}->quote(($repo->{autorefresh}?'Y':'N'))
        );
    }
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
    eval {
        $self->{DBH}->do($statement);
        $self->{REPO_DONE}->{$repo->{id}} = 1;
    };
    if($@)
    {
        if(!$self->migrate() && $@ =~ /Duplicate entry/i )
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, "Duplicate entry found, executing auto migration.");
            $self->migrate(1);
            my $ret = $self->_updateRepositories($repo);
            $self->migrate(0);
            return $ret;
        }
        elsif($@ =~ /Duplicate entry/i )
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, "Duplicate entry found. Need to cleanup Repository entries.");
            printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, "Please run 'smt sync' again.");
            $statement = sprintf("DELETE FROM Catalogs
                                   WHERE NAME = %s
                                     AND (TARGET = %s OR TARGET IS NULL)",
                                 $self->{DBH}->quote($repo->{name}),
                                 $self->{DBH}->quote($repo->{distro_target}));
            $self->{DBH}->do($statement);
            return 1;
        }
        else
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
            return 1;
        }
    }
    $self->_updateTargets($repo->{distro_target}, $repo->{distro_target});
    return 0;
}

sub _updateTargets
{
    my $self = shift;
    my $distro_description = shift || return;
    my $distro_target = shift || return;
    my $ret = 0;
    my $statement = "";

    if(exists $self->{TARGET_DONE}->{$distro_description})
    {
        if($self->{TARGET_DONE}->{$distro_description} ne "$distro_target")
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR,
                     "ambiguous distribution target data: '$distro_description' is $distro_target and ".
                     $self->{TARGET_DONE}->{$distro_description});
        }
        return $ret;
    }
    my $rows = 0;
    $statement = sprintf("UPDATE Targets SET TARGET = %s, SRC = 'S' WHERE OS = %s",
                         $self->{DBH}->quote($distro_target),
                         $self->{DBH}->quote($distro_description));
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
    eval {
        $rows = $self->{DBH}->do($statement);
        $self->{TARGET_DONE}->{$distro_description} = $distro_target if($rows > 0);
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        $ret += 1;
    }

    if ($rows < 1)
    {
        $statement = sprintf("INSERT INTO Targets (OS, TARGET, SRC) VALUES (%s, %s, 'S')",
                             $self->{DBH}->quote($distro_description),
                             $self->{DBH}->quote($distro_target));
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
        eval {
            $self->{DBH}->do($statement);
            $self->{TARGET_DONE}->{$distro_description} = $distro_target;
        };
        if($@)
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
            $ret += 1;
        }
    }
    return $ret;
}

sub _collectProductCatalogs
{
    my $self = shift;
    my $product = shift;
    my $repo = shift;
    $self->{PRODREPO}->{$product->{id}."-".$repo->{id}} = {
        'productdataid' => $product->{id},
        'catalogid' => $repo->{id},
        'optional' => ($repo->{enabled}?'N':'Y'),
        'installer_updates' => ($repo->{installer_updates}?'Y':'N')};
}

sub _updateProductCatalogs
{
    my $self = shift;
    my $err = 0;
    my $href = {};

    if ($self->migrate())
    {
        $self->{DBH}->do("DELETE FROM ProductCatalogs WHERE SRC='N'");
    }

    my $sql = "select productid, catalogid, optional, installer_updates from ProductCatalogs WHERE SRC = 'S'";
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $sql");
    eval {
        my $ref = $self->{DBH}->selectall_arrayref($sql, {Slice => {}});

        foreach my $v (@{$ref})
        {
            $href->{$v->{productid}."-".$v->{catalogid}} = $v;
        }
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        $err += 1;
    }

    foreach my $key (keys %{$self->{PRODREPO}})
    {
        my $product_id = SMT::Utils::lookupProductIdByDataId($self->{DBH}, $self->{PRODREPO}->{$key}->{productdataid},
                                                             'S', $self->{LOG}, $self->vblevel);
        my $repo_id = SMT::Utils::lookupCatalogIdByDataId($self->{DBH}, $self->{PRODREPO}->{$key}->{catalogid},
                                                          'S', $self->{LOG}, $self->vblevel);
        if (! $product_id)
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Unable to find Product ID for: ".$self->{PRODREPO}->{$key}->{productdataid});
            $err += 1;
        }
        if (! $repo_id)
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Unable to find Repository ID: ".$self->{PRODREPO}->{$key}->{catalogid});
            $err += 1;
        }
        my $pr_key = $product_id."-".$repo_id;
        if (!exists $href->{$pr_key})
        {
            $sql = sprintf("INSERT INTO ProductCatalogs (PRODUCTID, CATALOGID, OPTIONAL, INSTALLER_UPDATES, SRC)
                            VALUES (%s, %s, %s, %s, 'S')",
                           $self->{DBH}->quote($product_id),
                           $self->{DBH}->quote($repo_id),
                           $self->{DBH}->quote($self->{PRODREPO}->{$key}->{optional}),
                           $self->{DBH}->quote($self->{PRODREPO}->{$key}->{installer_updates})
                       );
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $sql");
            eval {
                $self->{DBH}->do($sql);
            };
            if($@)
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
                $err += 1;
            }
        }
        elsif($href->{$pr_key}->{optional} eq $self->{PRODREPO}->{$key}->{optional} &&
              $href->{$pr_key}->{installer_updates} eq $self->{PRODREPO}->{$key}->{installer_updates})
        {
            delete $href->{$pr_key};
        }
        else
        {
            $sql = sprintf("UPDATE ProductCatalogs SET OPTIONAL = %s, INSTALLER_UPDATES = %s
                            WHERE PRODUCTID = %s AND CATALOGID = %s",
                           $self->{DBH}->quote($self->{PRODREPO}->{$key}->{optional}),
                           $self->{DBH}->quote($self->{PRODREPO}->{$key}->{installer_updates}),
                           $self->{DBH}->quote($product_id),
                           $self->{DBH}->quote($repo_id));
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $sql");
            eval {
                $self->{DBH}->do($sql);
                delete $href->{$pr_key};
            };
            if($@)
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
                $err += 1;
            }
        }
    }
    foreach my $value (values %{$href})
    {
        $sql = sprintf("DELETE FROM ProductCatalogs
                         WHERE PRODUCTID = %s AND CATALOGID = %s
                           AND SRC = 'S'",
                           $value->{productid}, $value->{catalogid});
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $sql");
        eval {
            $self->{DBH}->do($sql);
        };
        if($@)
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
            $err += 1;
        }
    }
    return $err;
}

sub _addSubscription
{
    my $self = shift;
    my $subscr = shift || return 1;

    my $startdate = 0;
    $startdate = Date::Parse::str2time($subscr->{starts_at}) if($subscr->{starts_at});
    my $enddate = 0;
    $enddate = Date::Parse::str2time($subscr->{expires_at}) if($subscr->{expires_at});
    my $duration = 0;
    $duration =  (($startdate - $enddate) / 60*60*24) if($startdate && $enddate);
    my $product_classes = join(',', @{$subscr->{product_classes}});
    my $server_class = '';
    if (exists $subscr->{product_classes}->[0])
    {
        $server_class = SMT::Product::defaultServerClass($subscr->{product_classes}->[0]);
    }
    $server_class = 'ADDON' if(not $server_class);

    my $statement = sprintf("INSERT INTO Subscriptions VALUES (%s,%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                         $self->{DBH}->quote($subscr->{id}),
                         $self->{DBH}->quote($subscr->{regcode}),
                         $self->{DBH}->quote($subscr->{name}),
                         $self->{DBH}->quote($subscr->{type}),
                         $self->{DBH}->quote($subscr->{status}),
                         $self->{DBH}->quote(($startdate?SMT::Utils::getDBTimestamp($startdate):undef)),
                         $self->{DBH}->quote(($enddate?SMT::Utils::getDBTimestamp($enddate):undef)),
                         $self->{DBH}->quote($duration),
                         $self->{DBH}->quote($server_class),
                         $self->{DBH}->quote($product_classes),
                         $self->{DBH}->quote($subscr->{system_limit}),
                         $self->{DBH}->quote($subscr->{systems_count}),
                         $self->{DBH}->quote($subscr->{virtual_count}));
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
    eval {
        $self->{DBH}->do($statement);
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        return 1;
    }
    return 0;
}

sub _addClientSubscription
{
    my $self = shift;
    my $subscriptionId = shift || return 1;
    my $guid = shift || return 1;

    # skip it, if the client does not exist
    return 0 if(not SMT::Utils::lookupClientByGUID( $self->{DBH}, $guid, $self->{LOG}, $self->vblevel() ));
    my $ident = $guid."-".$subscriptionId;

    # skip duplicate entries bsc#905076
    next if (exists $self->{CACHE}->{'DB_ClientSubscriptions'}->{$ident});

    my $statement = sprintf("INSERT INTO ClientSubscriptions (SUBID, GUID) VALUES (%s,%s)",
                            $self->{DBH}->quote($subscriptionId),
                            $self->{DBH}->quote($guid));
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
    eval {
        $self->{DBH}->do($statement);
        $self->{CACHE}->{'DB_ClientSubscriptions'}->{$ident} = 1;
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        return 1;
    }
    return 0;
}

sub _updateProductData
{
    my $self = shift;
    my $json = shift;
    my $ret = 0;
    my $count = 0;
    my $sum = @$json;

    $sum += (@$json/10)*2+(@$json/100)*5;

    if(!defined $self->{DBH})
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Cannot connect to database.");
        return 1;
    }
    my $nuurl = URI->new($self->{CFG}->val("NU", "NUUrl", "https://updates.suse.com/"));
    push @{$self->{NUHOST}}, $nuurl->host;
    my $localhost = URI->new($self->{CFG}->val("LOCAL", "url"));
    $self->{LOCALHOST} = $localhost->host;
    $self->{LOCALSCHEME} = $localhost->scheme;

    foreach my $product (@$json)
    {
        $count++;
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO2, "Update DB (".int(($count/$sum*100))."%)\r", 1, 0);
        $ret += $self->_updateProducts($product);
    }
    $ret += $self->_updateProductCatalogs();
    $count += (@$json/10);
    printLog($self->{LOG}, $self->vblevel(), LOG_INFO2, "Update DB (".int(($count/$sum*100))."%)\r", 1, 0);
    $ret += $self->_updateExtensions();
    $count += (@$json/10);
    printLog($self->{LOG}, $self->vblevel(), LOG_INFO2, "Update DB (".int(($count/$sum*100))."%)\r", 1, 0);
    $ret += $self->_updateMigrations();
    $count = $sum;
    printLog($self->{LOG}, $self->vblevel(), LOG_INFO2, "Update DB (".int(($count/$sum*100))."%)\r", 1, 0);

    my $st1 = sprintf("Delete from Products where SRC='S' and PRODUCTDATAID not in (%s)",
                      "'".join("','", keys %{$self->{PROD_DONE}})."'");
    #my $st2 = sprintf("Delete from Catalogs where SRC='S' and CATALOGID not in (%s)",
    #                  "'".join("','", keys %{$self->{REPO_DONE}})."'");
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $st1");
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: Delete from Products where SRC='N'");
    #printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $st2");
    eval {
        $self->{DBH}->do($st1);
        $self->{DBH}->do("Delete from Products where SRC='N'");
        #$self->{DBH}->do($st2);
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
    }

    $self->_staticTargets();
    printLog($self->{LOG}, $self->vblevel(), LOG_INFO2, "\n", 1, 0);
    return $ret;
}

sub _updateSubscriptionData
{
    my $self   = shift;
    my $json   = shift;
    my $ret    = 0;
    my $retsub = 0;
    my $retreg = 0;
    my $count = 0;
    my $sum = @$json;

    if(!defined $self->{DBH})
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Cannot connect to database.");
        return 1;
    }

    # cleanup Subscriptions and ClientSubscriptions table
    # we always do a delete all and a new full insert.
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: DELETE FROM Subscriptions");
    eval {
        $self->{DBH}->do("DELETE FROM Subscriptions");
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        $ret += 1;
    }
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: DELETE FROM ClientSubscriptions");
    eval {
        $self->{DBH}->do("DELETE FROM ClientSubscriptions");
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        $ret += 1;
    }
    $self->{CACHE}->{'DB_ClientSubscriptions'} = {};

    foreach my $subscr (@$json)
    {
        $count++;
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO2, "Update DB (".int(($count/$sum*100))."%)\r", 1, 0);
        $retsub = $self->_addSubscription($subscr);
        $ret += $retsub;
        next if (not exists $subscr->{systems});
        foreach my $system (@{$subscr->{systems}})
        {
            $retreg = $self->_addClientSubscription($subscr->{id}, $system->{login});
            $ret += $retreg;
        }
    }
    printLog($self->{LOG}, $self->vblevel(), LOG_INFO2, "\n", 1, 0);
    return $ret;
}

sub _finalizeMirrorableRepos
{
    my $self   = shift;
    my $json   = shift || return 1;
    my $ret    = 0;

    if(!defined $self->{DBH})
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Cannot connect to database.");
        return 1;
    }

    my $sqlres = $self->{DBH}->selectall_hashref("select Name, Target, Mirrorable, ID, AUTHTOKEN
                                                    from Catalogs
                                                   where CATALOGTYPE = 'nu'",
                                                 ['Name', 'Target']);
    foreach my $repo (@{$json})
    {
        # zypp repos have no target
        next if (not $repo->{distro_target});
        my $updateNeeded = 0;
        my $authtoken = '';
        if(exists $sqlres->{$repo->{name}}->{$repo->{distro_target}}->{Mirrorable} )
        {
            if( uc($sqlres->{$repo->{name}}->{$repo->{distro_target}}->{Mirrorable}) ne "Y")
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_INFO1,
                         sprintf(__("* New mirrorable repository '%s %s' ."),
                                 $repo->{name}, $repo->{distro_target}));
                $updateNeeded = 1;
            }
            $authtoken = URI->new($repo->{url})->query;
            my $db_authtoken = $sqlres->{$repo->{name}}->{$repo->{distro_target}}->{AUTHTOKEN};
            $db_authtoken = '' if(!$db_authtoken);
            if( $db_authtoken ne "$authtoken" )
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG3,
                         sprintf("Token differ for %s %s\n%s vs\n%s\n",
                                 $repo->{name}, $repo->{distro_target},
                                 $db_authtoken,
                                 $authtoken));
                $updateNeeded = 1;
            }
            if($updateNeeded)
            {
                my $statement = sprintf("UPDATE Catalogs SET Mirrorable='Y', AUTHTOKEN=%s  WHERE ID = %s",
                                        $self->{DBH}->quote($authtoken),
                                        $self->{DBH}->quote($sqlres->{$repo->{name}}->{$repo->{distro_target}}->{ID}));
                printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
                $self->{DBH}->do( $statement );
            }
            delete $sqlres->{$repo->{name}}->{$repo->{distro_target}};
        }
    }

    foreach my $cname ( keys %{$sqlres})
    {
        foreach my $target ( keys %{$sqlres->{$cname}})
        {
            my $updateNeeded = 0;
            if(uc($sqlres->{$cname}->{$target}->{Mirrorable}) eq "Y")
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_INFO1,
                         sprintf(__("* repository not longer mirrorable '%s %s' ."), $cname, $target ));
                $updateNeeded = 1;
            }
            $updateNeeded = 1 if ($sqlres->{$cname}->{$target}->{AUTHTOKEN});
            if($updateNeeded)
            {
                my $statement = sprintf("UPDATE Catalogs SET Mirrorable='N', AUTHTOKEN='' WHERE ID=%s",
                                          $self->{DBH}->quote($sqlres->{$cname}->{$target}->{ID}) );
                printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
                $self->{DBH}->do( $statement );
            }
        }
    }
    return 0;
}

sub _migrateMachineData
{
    my $self = shift;
    my $pid = shift;
    my $new_productid = shift;
    my $ret = 0;

    my $query_productdataid = sprintf("SELECT PRODUCTDATAID FROM Products WHERE ID = %s AND SRC = 'N'",
                                      $self->{DBH}->quote($pid));

    my $ref = $self->{DBH}->selectrow_hashref($query_productdataid);
    my $old_productdataid = $ref->{PRODUCTDATAID};

    return $ret if ( not $old_productdataid);
    eval {
        $self->{DBH}->do(sprintf("UPDATE MachineData SET KEYNAME = %s WHERE KEYNAME = %s",
                                 $self->{DBH}->quote("product-name-$new_productid"),
                                 $self->{DBH}->quote("product-name-$old_productdataid")));
        $self->{DBH}->do(sprintf("UPDATE MachineData SET KEYNAME = %s WHERE KEYNAME = %s",
                                 $self->{DBH}->quote("product-version-$new_productid"),
                                 $self->{DBH}->quote("product-version-$old_productdataid")));
        $self->{DBH}->do(sprintf("UPDATE MachineData SET KEYNAME = %s WHERE KEYNAME = %s",
                                 $self->{DBH}->quote("product-arch-$new_productid"),
                                 $self->{DBH}->quote("product-arch-$old_productdataid")));
        $self->{DBH}->do(sprintf("UPDATE MachineData SET KEYNAME = %s WHERE KEYNAME = %s",
                                 $self->{DBH}->quote("product-rel-$new_productid"),
                                 $self->{DBH}->quote("product-rel-$old_productdataid")));
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        $ret += 1;
    }
    return $ret;
}

sub _staticTargets
{
    my $self = shift;

    my %staticTargets = (
        'i486' => 'i386',
        'i586' => 'i386',
        'i686' => 'i386',
        'SUSE edition of Moblin 2 (i586)' => 'sle-11-i586',
        'SUSE Linux Enterprise Desktop 11 (i586)' => 'sle-11-i586',
        'SUSE Linux Enterprise Server 11 (i586)' => 'sle-11-i586',
        'SUSE Linux Enterprise Server 11 (ia64)' => 'sle-11-ia64',
        'SUSE Linux Enterprise Server 11 (ppc64)' => 'sle-11-ppc64',
        'SUSE Linux Enterprise Server 11 (s390)' => 'sle-11-s390x',
        'SUSE Linux Enterprise Server 11 (s390x)' => 'sle-11-s390x',
        'SUSE Linux Enterprise Desktop 11 (x86_64)' => 'sle-11-x86_64',
        'SUSE Linux Enterprise Server 11 (x86_64)' => 'sle-11-x86_64',
        'SUSE Linux Enterprise Desktop 10 (i586)' => 'sled-10-i586',
        'SUSE Linux Enterprise Desktop 10.2 (i586)' => 'sled-10-i586',
        'SUSE Linux Enterprise Desktop 10.3 (i586)' => 'sled-10-i586',
        'SUSE Linux Enterprise Desktop 10.4 (i586)' => 'sled-10-i586',
        'SUSE Linux Enterprise Desktop 10 (x86_64)' => 'sled-10-x86_64',
        'SUSE Linux Enterprise Desktop 10.2 (x86_64)' => 'sled-10-x86_64',
        'SUSE Linux Enterprise Desktop 10.3 (x86_64)' => 'sled-10-x86_64',
        'SUSE Linux Enterprise Desktop 10.4 (x86_64)' => 'sled-10-x86_64',
        'Novell Open Enterprise Server 10 (i586)' => 'sles-10-i586',
        'SUSE Linux Enterprise Server 10 (i586)' => 'sles-10-i586',
        'SUSE Linux Enterprise Server 10.2 (i586)' => 'sles-10-i586',
        'SUSE Linux Enterprise Server 10.3 (i586)' => 'sles-10-i586',
        'SUSE Linux Enterprise Server 10.4 (i586)' => 'sles-10-i586',
        'Novell Open Enterprise Server 10 (ia64)' => 'sles-10-ia64',
        'SUSE Linux Enterprise Server 10 (ia64)' => 'sles-10-ia64',
        'SUSE Linux Enterprise Server 10.2 (ia64)' => 'sles-10-ia64',
        'SUSE Linux Enterprise Server 10.3 (ia64)' => 'sles-10-ia64',
        'SUSE Linux Enterprise Server 10.4 (ia64)' => 'sles-10-ia64',
        'Novell Open Enterprise Server 10 (ppc)' => 'sles-10-ppc',
        'SUSE Linux Enterprise Server 10 (ppc)' => 'sles-10-ppc',
        'SUSE Linux Enterprise Server 10.2 (ppc)' => 'sles-10-ppc',
        'SUSE Linux Enterprise Server 10.3 (ppc)' => 'sles-10-ppc',
        'SUSE Linux Enterprise Server 10.4 (ppc)' => 'sles-10-ppc',
        'Novell Open Enterprise Server 10 (s390)' => 'sles-10-s390',
        'SUSE Linux Enterprise Server 10 (s390)' => 'sles-10-s390',
        'SUSE Linux Enterprise Server 10.2 (s390)' => 'sles-10-s390',
        'SUSE Linux Enterprise Server 10.3 (s390)' => 'sles-10-s390',
        'SUSE Linux Enterprise Server 10.4 (s390)' => 'sles-10-s390',
        'Novell Open Enterprise Server 10 (s390x)' => 'sles-10-s390x',
        'SUSE Linux Enterprise Server 10 (s390x)' => 'sles-10-s390x',
        'SUSE Linux Enterprise Server 10.2 (s390x)' => 'sles-10-s390x',
        'SUSE Linux Enterprise Server 10.3 (s390x)' => 'sles-10-s390x',
        'SUSE Linux Enterprise Server 10.4 (s390x)' => 'sles-10-s390x',
        'Novell Open Enterprise Server 10 (x86_64)' => 'sles-10-x86_64',
        'SUSE Linux Enterprise Server 10 (x86_64)' => 'sles-10-x86_64',
        'SUSE Linux Enterprise Server 10.2 (x86_64)' => 'sles-10-x86_64',
        'SUSE Linux Enterprise Server 10.3 (x86_64)' => 'sles-10-x86_64',
        'SUSE Linux Enterprise Server 10.4 (x86_64)' => 'sles-10-x86_64',
        'SuSE Linux Enterprise Server 9 (x86_64)' => 'sles-10-x86_64',
        );
    foreach my $distro_description (keys %staticTargets)
    {
        $self->_updateTargets($distro_description, $staticTargets{$distro_description});
    }
}

sub _machinedata_from_db
{
    my $self = shift;
    my $regdata = shift;
    my $translation = {};

    foreach my $pair (@{$regdata})
    {
        if($pair->{KEYNAME} eq "machinedata" && $pair->{VALUE})
        {
            # machinedata comes direct from SUSEConnect and we use it 1:1
            return JSON::decode_json($pair->{VALUE});
        }
        # else we translate suse_register reported hardware data to SCC/SUSEConnect format
        elsif($pair->{KEYNAME} eq "host" && $pair->{VALUE} && ! exists $translation->{hwinfo}->{hypervisor})
        {
            $translation->{hwinfo}->{hypervisor} = "suseRegister.conf";
        }
        elsif($pair->{KEYNAME} eq "virttype" && $pair->{VALUE})
        {
            $translation->{hwinfo}->{hypervisor} = $pair->{VALUE};
        }
        elsif($pair->{KEYNAME} eq "hostname" && $pair->{VALUE})
        {
            $translation->{hwinfo}->{hostname} = $pair->{VALUE};
        }
        elsif($pair->{KEYNAME} eq "platform" && $pair->{VALUE})
        {
            $translation->{hwinfo}->{arch} = $pair->{VALUE};
        }
        elsif($pair->{KEYNAME} eq "cpu-count" && $pair->{VALUE})
        {
            if($pair->{VALUE} =~ /CPUSockets\s*:\s*(\d+)/)
            {
                $translation->{hwinfo}->{sockets} = $1;
            }
            if($pair->{VALUE} =~ /CPUCores\s*:\s*(\d+)/)
            {
                $translation->{hwinfo}->{cpus} = $1;
            }
        }
    }
    return $translation;
}

sub _products_from_db
{
    my $self = shift;
    my $products = shift;
    my $regdata = shift;
    my $prdout = [];
    my $r = {};

    foreach my $PHash (@{$products})
    {
        if(!exists $PHash->{ID} || ! $PHash->{ID} ||
           !exists $PHash->{PRODUCTDATAID} || ! $PHash->{PRODUCTDATAID})
        {
            next;
        }
        my $p = {};

        foreach my $pair (@{$regdata})
        {
            if($pair->{KEYNAME} eq "product-name-".$PHash->{ID} && $pair->{VALUE})
            {
                $p->{identifier} = $pair->{VALUE};
            }
            elsif($pair->{KEYNAME} eq "product-version-".$PHash->{ID} && $pair->{VALUE})
            {
                $p->{version} = $pair->{VALUE};
            }
            elsif($pair->{KEYNAME} eq "product-arch-".$PHash->{ID} && $pair->{VALUE})
            {
                $p->{arch} = $pair->{VALUE};
            }
            elsif($pair->{KEYNAME} eq "product-rel-".$PHash->{ID} && $pair->{VALUE})
            {
                $p->{release_type} = $pair->{VALUE};
            }
            elsif($pair->{KEYNAME} eq "product-token-".$PHash->{ID} && $pair->{VALUE})
            {
                $r->{$pair->{VALUE}} = 1;
            }
            # testing PRODUCTDATAID for compatibility reason
            # ID > 10000 - NCC productdataid starts with 1
            elsif($pair->{KEYNAME} eq "product-name-".$PHash->{PRODUCTDATAID} && $pair->{VALUE})
            {
                $p->{identifier} = $pair->{VALUE};
            }
            elsif($pair->{KEYNAME} eq "product-version-".$PHash->{PRODUCTDATAID} && $pair->{VALUE})
            {
                $p->{version} = $pair->{VALUE};
            }
            elsif($pair->{KEYNAME} eq "product-arch-".$PHash->{PRODUCTDATAID} && $pair->{VALUE})
            {
                $p->{arch} = $pair->{VALUE};
            }
            elsif($pair->{KEYNAME} eq "product-rel-".$PHash->{PRODUCTDATAID} && $pair->{VALUE})
            {
                $p->{release_type} = $pair->{VALUE};
            }
            elsif($pair->{KEYNAME} eq "product-token-".$PHash->{PRODUCTDATAID} && $pair->{VALUE})
            {
                $r->{$pair->{VALUE}} = 1;
            }
            elsif($pair->{KEYNAME} =~ "^regcode-" && $pair->{VALUE})
            {
                $r->{$pair->{VALUE}} = 1;
            }
        }
        $p->{id} = $PHash->{PRODUCTDATAID};
        push @{$prdout}, $p;
    }
    my @regout = keys %$r;
    return ($prdout, \@regout);
}

#
# copy from NCCRegTools
#
sub _deleteRegistrationLocal
{
    my $self = shift;
    my @guids = @_;

    my $where = "";
    if(@guids == 0)
    {
        return 1;
    }

    foreach my $guid (@guids)
    {
        my $found = 0;

        $where = sprintf("GUID = %s", $self->{DBH}->quote( $guid ) );

        my $statement = "DELETE FROM Registration where ".$where;

        my $res = $self->{DBH}->do($statement);

        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Statement: $statement Result: $res") ;

        $found = 1 if( $res > 0 );

        $statement = "DELETE FROM Clients where ".$where;

        $res = $self->{DBH}->do($statement);

        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Statement: $statement Result: $res") ;

        $statement = "DELETE FROM MachineData where ".$where;

        $res = $self->{DBH}->do($statement);

        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Statement: $statement Result: $res") ;

        #FIXME: does it make sense to remove this GUID from ClientSubscriptions ?

        if($found)
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, sprintf("Successfully delete registration locally : %s", $guid));
        }
        else
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, sprintf("Delete registration locally failed: %s", $guid));
        }
    }

    return 1;
}


1;

=back

=head1 AUTHOR

mc@suse.de

=head1 COPYRIGHT

Copyright 2014 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut
