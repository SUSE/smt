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
use SMT::DB;

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
    $self->{EXT_DONE} = {};
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

=item services

NOT YET IMPLEMENTED

Update distro_targets.
Return number of errors.

=cut

sub services
{
    my $self = shift;
    my $name = "services";
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
        my $ret = undef;
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
    if (! $input)
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

    foreach my $k (keys %{$product})
    {
        $product->{$k} = '' if(!defined $product->{$k});
    }
    if (! $self->migrate() &&
        (my $pid = SMT::Utils::lookupProductIdByDataId($self->{DBH}, $product->{id}, 'S', $self->{LOG}, $self->vblevel)))
    {
        $statement = sprintf("UPDATE Products
                                 SET product = %s, version = %s,
                                     rel = %s, arch = %s,
                                     friendly = %s,
                                     product_class = %s, productdataid = %s,
                                     cpe = %s, description = %s, eula_url = %s,
                                     former_identifier = %s, product_type = %s
                               WHERE id = %s",
                             $self->{DBH}->quote($product->{identifier}),
                             $self->{DBH}->quote($product->{version}),
                             $self->{DBH}->quote($product->{release_type}),
                             $self->{DBH}->quote($product->{arch}),
                             $self->{DBH}->quote($product->{friendly_name}),
                             $self->{DBH}->quote($product->{product_class}),
                             $self->{DBH}->quote($product->{id}),
                             $self->{DBH}->quote($product->{cpe}),
                             $self->{DBH}->quote($product->{description}),
                             $self->{DBH}->quote($product->{eula_url}),
                             $self->{DBH}->quote($product->{former_identifier}),
                             $self->{DBH}->quote($product->{product_type}),
                             $self->{DBH}->quote($pid)
        );
    }
    elsif ($self->migrate() && ($pid = SMT::Utils::lookupProductIdByName($self->{DBH}, $product->{identifier},
                                                                         $product->{version},
                                                                         $product->{release_type},
                                                                         $product->{arch},
                                                                         $self->{LOG}, $self->vblevel)))
    {
        $statement = sprintf("UPDATE Products
                                 SET product = %s, version = %s,
                                     rel = %s, arch = %s,
                                     friendly = %s,
                                     product_class = %s, productdataid = %s,
                                     cpe = %s, description = %s, eula_url = %s,
                                     former_identifier = %s, product_type = %s,
                                     src = 'S'
                               WHERE id = %s",
                             $self->{DBH}->quote($product->{identifier}),
                             $self->{DBH}->quote($product->{version}),
                             $self->{DBH}->quote($product->{release_type}),
                             $self->{DBH}->quote($product->{arch}),
                             $self->{DBH}->quote($product->{friendly_name}),
                             $self->{DBH}->quote($product->{product_class}),
                             $self->{DBH}->quote($product->{id}),
                             $self->{DBH}->quote($product->{cpe}),
                             $self->{DBH}->quote($product->{description}),
                             $self->{DBH}->quote($product->{eula_url}),
                             $self->{DBH}->quote($product->{former_identifier}),
                             $self->{DBH}->quote($product->{product_type}),
                             $self->{DBH}->quote($pid)
        );
    }
    else
    {
        $statement = sprintf("INSERT INTO Products (id, product, version, rel, arch, friendly,
                              product_class, cpe, description, eula_url, productdataid,
                              former_identifier, product_type, src)
                              VALUES (nextval('products_id_seq'),
                                      %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'S')",
                             $self->{DBH}->quote($product->{identifier}),
                             $self->{DBH}->quote($product->{version}),
                             $self->{DBH}->quote($product->{release_type}),
                             $self->{DBH}->quote($product->{arch}),
                             $self->{DBH}->quote($product->{friendly_name}),
                             $self->{DBH}->quote($product->{product_class}),
                             $self->{DBH}->quote($product->{cpe}),
                             $self->{DBH}->quote($product->{description}),
                             $self->{DBH}->quote($product->{eula_url}),
                             $self->{DBH}->quote($product->{id}),
                             $self->{DBH}->quote($product->{former_identifier}),
                             $self->{DBH}->quote($product->{product_type})
        );
    }
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
    eval {
        $self->{DBH}->do($statement);
        $self->{PROD_DONE}->{$product->{id}} = 1;
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        $retprd = 1;
    }

    foreach my $repo (@{$product->{repositories}})
    {
        my $retcat = $self->_updateRepositories($repo);
        $ret += $retcat;

        # if either product or repository could not be added,
        # we will fail to add the relation.
        next if ( $retprd || $retcat);
        $ret += $self->_updateProductRepositories($product, $repo);
    }
    $ret += $retprd;

    foreach my $ext (@{$product->{extensions}})
    {
        $ret += $self->_updateProducts($ext);
        $ret += $self->_updateExtension($product->{id}, $ext->{id});
    }

    return $ret;
}

sub _updateExtension
{
    my $self  = shift || return 1;
    my $prdid = shift || return 1;
    my $extid = shift || return 1;

    # we inserted/update this product already in this run
    # so let's skip it
    return 0 if(exists $self->{EXT_DONE}->{"$prdid-$extid"});


    my $sql = sprintf("
        INSERT INTO ProductExtensions VALUES (
            (SELECT id from Products WHERE productdataid = %s AND src = 'S'),
            (SELECT id from Products WHERE productdataid = %s AND src = 'S'),
            'S')",
            $self->{DBH}->quote($prdid),
            $self->{DBH}->quote($extid));
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $sql");
    eval {
        $self->{DBH}->do($sql);
        $self->{EXT_DONE}->{"$prdid-$extid"} = 1;
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        return 1;
    }
    return 0;
}

sub _updateRepositories
{
    my $self = shift;
    my $repo = shift;
    my $statement = "";
    my $localpath = "";
    my $repotype = "";
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
        $repotype = 'nu';
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
        $repotype = 'zypp';
    }

    if (! $self->migrate() &&
        (my $cid = SMT::Utils::lookupRepositoryIdByDataId($self->{DBH}, $repo->{id}, 'S', $self->{LOG}, $self->vblevel)))
    {
        $statement = sprintf("UPDATE Repositories
                                 SET name = %s, description = %s,
                                     target = %s, localpath = %s,
                                     exthost = %s, exturl = %s,
                                     repotype = %s, repo_id = %s,
                                     autorefresh = %s
                               WHERE id = %s",
                             $self->{DBH}->quote($repo->{name}),
                             $self->{DBH}->quote($repo->{description}),
                             $self->{DBH}->quote($repo->{distro_target}?$repo->{distro_target}:''),
                             $self->{DBH}->quote($localpath),
                             $self->{DBH}->quote($exthost),
                             $self->{DBH}->quote($repo->{url}),
                             $self->{DBH}->quote($repotype),
                             $self->{DBH}->quote($repo->{id}),
                             $self->{DBH}->quote(($repo->{autorefresh}?'Y':'N')),
                             $self->{DBH}->quote($cid)
        );
    }
    elsif ($self->migrate() &&
           ($cid = SMT::Utils::lookupRepositoryIdByName($self->{DBH}, $repo->{name}, $repo->{distro_target}, $self->{LOG}, $self->vblevel)))
    {
        $statement = sprintf("UPDATE Repositories
                                 SET name = %s, description = %s,
                                     target = %s, localpath = %s,
                                     exthost = %s, exturl = %s,
                                     repotype = %s, repo_id = %s,
                                     autorefresh = %s,
                                     src = 'S'
                               WHERE id = %s",
                             $self->{DBH}->quote($repo->{name}),
                             $self->{DBH}->quote($repo->{description}),
                             $self->{DBH}->quote($repo->{distro_target}?$repo->{distro_target}:''),
                             $self->{DBH}->quote($localpath),
                             $self->{DBH}->quote($exthost),
                             $self->{DBH}->quote($repo->{url}),
                             $self->{DBH}->quote($repotype),
                             $self->{DBH}->quote($repo->{id}),
                             $self->{DBH}->quote(($repo->{autorefresh}?'Y':'N')),
                             $self->{DBH}->quote($cid)
        );
    }
    else
    {
        $statement = sprintf("INSERT INTO Repositories (id, name, description, target, localpath,
                              exthost, exturl, repotype, repo_id, autorefresh, src)
                              VALUES (nextval('repos_id_seq'), %s, %s, %s, %s, %s, %s, %s, %s, %s, 'S')",
                             $self->{DBH}->quote($repo->{name}),
                             $self->{DBH}->quote($repo->{description}),
                             $self->{DBH}->quote($repo->{distro_target}?$repo->{distro_target}:''),
                             $self->{DBH}->quote($localpath),
                             $self->{DBH}->quote($exthost),
                             $self->{DBH}->quote($repo->{url}),
                             $self->{DBH}->quote($repotype),
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
        if( $@ =~ /Duplicate entry/i )
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_INFO1, "Duplicate entry found, executing auto migration.", 0, 1);
            $self->migrate(1);
            my $ret = $self->_updateRepositories($repo);
            $self->migrate(0);
            return $ret;
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
    $statement = sprintf("UPDATE Targets SET target = %s, src = 'S' WHERE os = %s",
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
        $statement = sprintf("INSERT INTO Targets (os, target, src) VALUES (%s, %s, 'S')",
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

sub _updateProductRepositories
{
    my $self = shift;
    my $product = shift;
    my $repo = shift;
    my $ret = 0;
    my $product_id = SMT::Utils::lookupProductIdByDataId($self->{DBH}, $product->{id}, 'S', $self->{LOG}, $self->vblevel);
    my $repo_id = SMT::Utils::lookupRepositoryIdByDataId($self->{DBH}, $repo->{id}, 'S', $self->{LOG}, $self->vblevel);
    if (! $product_id)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Unable to find Product ID for: ".$product->{id});
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Unable to find Product ID for: ".Data::Dumper->Dump([$product]));
        exit 1;
        return 1;
    }
    if (! $repo_id)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Unable to find Repository ID: ".$repo->{id});
        return 1;
    }
    my $statement = sprintf("DELETE FROM ProductRepositories
                              WHERE product_id = %s
                                AND repository_id = %s",
                            $self->{DBH}->quote($product_id),
                            $self->{DBH}->quote($repo_id)
    );
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
    eval {
        $self->{DBH}->do($statement);
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        $ret += 1;
    }

    $statement = sprintf("INSERT INTO ProductRepositories (product_id, repository_id, optional, src)
                          VALUES (%s, %s, %s, 'S')",
                         $self->{DBH}->quote($product_id),
                         $self->{DBH}->quote($repo_id),
                         $self->{DBH}->quote(($repo->{enabled}?'N':'Y')));
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
    eval {
        $self->{DBH}->do($statement);
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        $ret += 1;
    }
    return $ret;
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
    my $subid = $self->{DBH}->sequence_nextval('subscriptions_id_seq');

    my $statement = sprintf("INSERT INTO Subscriptions
                                         (id, subid, regcode, subname, subtype, substatus,
                                          substartdate, subenddate, product_class, nodecount,
                                          consumed, consumedvirt)
                                  VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                            $self->{DBH}->quote($subid),
                            $self->{DBH}->quote($subscr->{id}),
                            $self->{DBH}->quote($subscr->{regcode}),
                            $self->{DBH}->quote($subscr->{name}),
                            $self->{DBH}->quote($subscr->{type}),
                            $self->{DBH}->quote($subscr->{status}),
                            $self->{DBH}->quote(($startdate?SMT::Utils::getDBTimestamp($startdate):undef)),
                            $self->{DBH}->quote(($enddate?SMT::Utils::getDBTimestamp($enddate):undef)),
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

    my $statement = sprintf("INSERT INTO ClientSubscriptions
                                         (subscription_id, client_id)
                                  VALUES (
                                          (SELECT id FROM Subscriptions WHERE subid = %s),
                                          (SELECT id FROM Clients WHERE guid = %s),
                                         )",
                            $self->{DBH}->quote($subscriptionId),
                            $self->{DBH}->quote($guid));
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

sub _updateProductData
{
    my $self = shift;
    my $json = shift;
    my $ret = 0;
    my $count = 0;
    my $sum = @$json;

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

    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: DELETE FROM ProductExtensions WHERE SRC='S'");
    eval {
        $self->{DBH}->do("DELETE FROM ProductExtensions WHERE SRC='S'");
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        $ret += 1;
    }

    foreach my $product (@$json)
    {
        $count++;
        printLog($self->{LOG}, $self->vblevel(), LOG_INFO2, "Update DB (".int(($count/$sum*100))."%)\r", 1, 0);
        $ret += $self->_updateProducts($product);
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
    # FIXME: delete all is not an option anymore
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

    my $sqlres = $self->{DBH}->selectall_hashref("SELECT name, target, mirrorable, id, authtoken
                                                    FROM Repositories
                                                   WHERE repotype = 'nu'",
                                                 ['name', 'target']);
    foreach my $repo (@{$json})
    {
        # zypp repos have no target
        next if (not $repo->{distro_target});
        my $updateNeeded = 0;
        my $authtoken = '';
        if(exists $sqlres->{$repo->{name}}->{$repo->{distro_target}}->{mirrorable} )
        {
            if( uc($sqlres->{$repo->{name}}->{$repo->{distro_target}}->{mirrorable}) ne "Y")
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_INFO1,
                         sprintf(__("* New mirrorable repository '%s %s' ."),
                                 $repo->{name}, $repo->{distro_target}));
                $updateNeeded = 1;
            }
            $authtoken = URI->new($repo->{url})->query;
            my $db_authtoken = $sqlres->{$repo->{name}}->{$repo->{distro_target}}->{authtoken};
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
                my $statement = sprintf("UPDATE Repositories SET mirrorable='Y', authtoken=%s WHERE id = %s",
                                        $self->{DBH}->quote($authtoken),
                                        $self->{DBH}->quote($sqlres->{$repo->{name}}->{$repo->{distro_target}}->{id}));
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
            if(uc($sqlres->{$cname}->{$target}->{mirrorable}) eq "Y")
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_INFO1,
                         sprintf(__("* repository not longer mirrorable '%s %s' ."), $cname, $target ));
                $updateNeeded = 1;
            }
            $updateNeeded = 1 if ($sqlres->{$cname}->{$target}->{authtoken});
            if($updateNeeded)
            {
                my $statement = sprintf("UPDATE Repositories SET mirrorable='N', authtoken='' WHERE id=%s",
                                          $self->{DBH}->quote($sqlres->{$cname}->{$target}->{id}) );
                printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
                $self->{DBH}->do( $statement );
            }
        }
    }
    return 0;
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

1;

=back

=head1 AUTHOR

mc@suse.de

=head1 COPYRIGHT

Copyright 2014 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut
