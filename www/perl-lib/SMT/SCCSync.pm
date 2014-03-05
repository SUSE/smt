package SMT::SCCSync;
use strict;

use URI;
use SMT::SCCAPI;
use SMT::Utils;
use File::Temp;
use DBI qw(:sql_types);

use Data::Dumper;


# constructor
sub new
{
    my $pkgname = shift;
    my %opt   = @_;

    my $self  = {};

    $self->{URI}   = undef;
    $self->{VBLEVEL} = 0;
    $self->{LOG}   = undef;
    $self->{USERAGENT}  = undef;

    $self->{MAX_REDIRECTS} = 5;

    $self->{AUTHUSER} = "";
    $self->{AUTHPASS} = "";

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

    if(exists $opt{vblevel} && defined $opt{vblevel})
    {
        $self->{VBLEVEL} = $opt{vblevel};
    }

    if(exists $opt{log} && defined $opt{log} && $opt{log})
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
                                    useragent => $self->{USERAGENT});
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


sub products
{
    my $self = shift;
    my $input = undef;

    if($self->{FROMDIR} && -d $self->{FROMDIR})
    {
        open( FH, '<', $self->{FROMDIR}."/products.json" ) and do
        {
            my $json_text   = <FH>;
            $input = JSON::decode_json( $json_text );
            close FH;
        };

    }
    else
    {
        $input = $self->{API}->products();
    }
    if (! $input)
    {
        return 1;
    }
    if(defined $self->{TODIR})
    {
        open( FH, '>', $self->{TODIR}."/products.json") or do
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
        my $ret = $self->_updateData($input);
        return $ret;
    }
}

sub lookupProductIdByDataId
{
    my $self = shift;
    my $id = shift;
    my $src = shift;

    my $query_product = sprintf("SELECT ID FROM Products WHERE PRODUCTDATAID = %s",
                                $self->{DBH}->quote($id));
    $query_product .= sprintf(" AND SRC = %s", $self->{DBH}->quote($src)) if $src;

    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $query_product");
    my $ref = $self->{DBH}->selectrow_hashref($query_product);
    return $ref->{ID};
}

sub lookupProductIdByName
{
    my $self = shift;
    my $name = shift;
    my $version = shift;
    my $arch = shift;
    my $release = shift;

    my $statement = "SELECT ID, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER FROM Products where ";

    $statement .= "PRODUCTLOWER = ".$self->{DBH}->quote(lc($name));

    $statement .= " AND (";
    $statement .= "VERSIONLOWER=".$self->{DBH}->quote(lc($version))." OR " if($version);
    $statement .= "VERSIONLOWER IS NULL)";

    $statement .= " AND (";
    $statement .= "RELLOWER=".$self->{DBH}->quote(lc($release))." OR " if($release);
    $statement .= "RELLOWER IS NULL)";

    $statement .= " AND (";
    $statement .= "ARCHLOWER=".$self->{DBH}->quote(lc($arch))." OR " if($arch);
    $statement .= "ARCHLOWER IS NULL)";

    # order by name,version,release,arch with NULL values at the end (bnc#659912)
    $statement .= " ORDER BY PRODUCTLOWER, VERSIONLOWER DESC, RELLOWER DESC, ARCHLOWER DESC";

    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
    my $pl = $self->{DBH}->selectall_arrayref($statement, {Slice => {}});

    if(@$pl == 1)
    {
        # Only one match found.
        return $pl->[0]->{ID};
    }
    elsif(@$pl > 1)
    {
        my $found = 0;
        # Do we have an exact match?
        foreach my $prod (@$pl)
        {
            if(lc($prod->{VERSIONLOWER}) eq lc($version) &&
               lc($prod->{ARCHLOWER}) eq  lc($arch)&&
               lc($prod->{RELLOWER}) eq lc($release))
            {
                # Exact match found.
                return $prod->{ID};
            }
        }
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "No exact match found for: $name $version $release $arch. Choose the first one.");
        return $pl->[0]->{ID};
    }
    printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "No Product match found for: $name $version $release $arch");
    return undef;
}


sub lookupCatalogIdByDataId
{
    my $self = shift;
    my $id = shift;
    my $src = shift;

    my $query_product = sprintf("SELECT ID FROM Catalogs WHERE CATALOGID = %s",
                                $self->{DBH}->quote($id));
    $query_product .= sprintf(" AND SRC = %s", $self->{DBH}->quote($src)) if $src;

    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $query_product");
    my $ref = $self->{DBH}->selectrow_hashref($query_product);
    return $ref->{ID};
}

sub lookupCatalogIdByName
{
    my $self = shift;
    my $name = shift;
    my $target = shift;

    my $statement = "SELECT ID FROM Catalogs where ";

    $statement .= "NAME = ".$self->{DBH}->quote($name);

    if($target)
    {
        $statement .= " AND TARGET=".$self->{DBH}->quote($target);
    }
    else
    {
        $statement .= " AND TARGET IS NULL";
    }

    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
    my $pl = $self->{DBH}->selectall_arrayref($statement, {Slice => {}});

    if(@$pl == 1)
    {
        # Only one match found.
        return $pl->[0]->{ID};
    }
    printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "No match found for: $name $target");
    return undef;
}


###############################################################################
###############################################################################
###############################################################################
###############################################################################

sub _updateProducts
{
    my $self = shift;
    my $product = shift;

    my $statement = "";
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
    <param id="hostname" description="" command="uname -n" class="mandatory"/>
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

    if ($self->lookupProductIdByDataId($product->{id}, 'S'))
    {
        $statement = sprintf("UPDATE Products
                                 SET PRODUCT = %s, VERSION = %s,
                                     REL = %s, ARCH = %s,
                                     PRODUCTLOWER = %s, VERSIONLOWER = %s,
                                     RELLOWER = %s, ARCHLOWER = %s,
                                     FRIENDLY = %s, PRODUCT_LIST = %s,
                                     PRODUCT_CLASS = %s
                               WHERE PRODUCTDATAID = %s
                                 AND SRC = 'S'",
                             $self->{DBH}->quote($product->{zypper_name}),
                             $self->{DBH}->quote($product->{zypper_version}),
                             $self->{DBH}->quote($product->{release}),
                             $self->{DBH}->quote($product->{arch}),
                             $self->{DBH}->quote(lc($product->{zypper_name})),
                             $self->{DBH}->quote(lc($product->{zypper_version})),
                             $self->{DBH}->quote(lc($product->{release})),
                             $self->{DBH}->quote(lc($product->{arch})),
                             $self->{DBH}->quote($product->{friendly}),
                             $self->{DBH}->quote(($product->{product_list}?'Y':'N')),
                             $self->{DBH}->quote($product->{product_class}),
                             $self->{DBH}->quote($product->{id})
        );
    }
    else
    {
        $statement = sprintf("INSERT INTO Products (PRODUCT, VERSION, REL, ARCH,
                              PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER,
                              PARAMLIST, NEEDINFO, SERVICE,
                              FRIENDLY, PRODUCT_LIST, PRODUCT_CLASS, PRODUCTDATAID, SRC)
                              VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'S')",
                             $self->{DBH}->quote($product->{zypper_name}),
                             $self->{DBH}->quote($product->{zypper_version}),
                             $self->{DBH}->quote($product->{release}),
                             $self->{DBH}->quote($product->{arch}),
                             $self->{DBH}->quote(lc($product->{zypper_name})),
                             $self->{DBH}->quote(lc($product->{zypper_version})),
                             $self->{DBH}->quote(lc($product->{release})),
                             $self->{DBH}->quote(lc($product->{arch})),
                             $self->{DBH}->quote($paramlist),
                             $self->{DBH}->quote($needinfo),
                             $self->{DBH}->quote($service),
                             $self->{DBH}->quote($product->{friendly}),
                             $self->{DBH}->quote(($product->{product_list}?'Y':'N')),
                             $self->{DBH}->quote($product->{product_class}),
                             $self->{DBH}->quote($product->{id}));
    }
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
    eval {
        $self->{DBH}->do($statement);
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
    }
}

sub _updateRepositories
{
    my $self = shift;
    my $repo = shift;
    my $statement = "";

    my $localpath = "RPMMD/".$repo->{name};
    if (grep( ($_ == 'nu' || $_ == 'ris' || $_ == 'yum'), @{$repo->{flags}}))
    {
        $localpath = $repo->{name}."/".$repo->{distro_target};
    }
    # FIXME: add sles10sp1 ATI and nVidia special
    my $exthost = URI->new($repo->{url});
    $exthost->path(undef);
    $exthost->fragment(undef);
    $exthost->query(undef);

    my $catalogtype = 'nu';
    if (grep( ($_ == 'zypp' || $_ == 'repomd'), @{$repo->{flags}}))
    {
        $catalogtype = 'zypp';
    }
    elsif (grep( ($_ == 'yum'), @{$repo->{flags}}))
    {
        $catalogtype = 'yum';
    }


    if ($self->lookupCatalogIdByDataId($repo->{id}, 'S'))
    {
        $statement = sprintf("UPDATE Catalogs
                                 SET NAME = %s, DESCRIPTION = %s,
                                     TARGET = %s, LOCALPATH = %s,
                                     EXTHOST = %s, EXTURL = %s,
                                     CATALOGTYPE = %s
                               WHERE CATALOGID = %s
                                 AND SRC = 'S'",
                             $self->{DBH}->quote($repo->{name}),
                             $self->{DBH}->quote($repo->{description}),
                             $self->{DBH}->quote($repo->{distro_target}),
                             $self->{DBH}->quote($localpath),
                             $self->{DBH}->quote($exthost),
                             $self->{DBH}->quote($repo->{url}),
                             $self->{DBH}->quote($catalogtype),
                             $self->{DBH}->quote($repo->{id})
        );
    }
    else
    {
        $statement = sprintf("INSERT INTO Catalogs (NAME, DESCRIPTION, TARGET, LOCALPATH,
                              EXTHOST, EXTURL, CATALOGTYPE, CATALOGID, SRC)
                              VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 'S')",
                             $self->{DBH}->quote($repo->{name}),
                             $self->{DBH}->quote($repo->{description}),
                             $self->{DBH}->quote($repo->{distro_target}),
                             $self->{DBH}->quote($localpath),
                             $self->{DBH}->quote($exthost),
                             $self->{DBH}->quote($repo->{url}),
                             $self->{DBH}->quote($catalogtype),
                             $self->{DBH}->quote($repo->{id})
        );
    }
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
    eval {
        $self->{DBH}->do($statement);
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
    }
}

sub _updateProductCatalogs
{
    my $self = shift;
    my $product = shift;
    my $repo = shift;
    my $product_id = $self->lookupProductIdByDataId($product->{id}, 'S');
    my $repo_id = $self->lookupCatalogIdByDataId($repo->{id}, 'S');
    if (! $product_id)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Unable to find Product ID for: ".$product->{id});
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "Unable to find Product ID for: ".Data::Dumper->Dump([$product]));
        return;
    }
    if (! $repo_id)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Unable to find Repository ID: ".$repo->{id});
        return;
    }
    my $statement = sprintf("DELETE FROM ProductCatalogs
                              WHERE PRODUCTID = %s AND CATALOGID = %s",
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
    }
    my $optional = ((grep $_ == 'optional', @{$repo->{flags}})?"Y":"N");

    $statement = sprintf("INSERT INTO ProductCatalogs (PRODUCTID, CATALOGID, OPTIONAL, SRC)
                          VALUES (%s, %s, %s, 'S')",
                         $self->{DBH}->quote($product_id),
                         $self->{DBH}->quote($repo_id),
                         $self->{DBH}->quote($optional));
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
    eval {
        $self->{DBH}->do($statement);
    };
    if($@)
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
    }
}

sub _updateData
{
    my $self = shift;
    my $json = shift;

    if(!defined $self->{DBH})
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Cannot connect to database.");
        return 1;
    }

    foreach my $product (@$json)
    {
        $self->_updateProducts($product);

        foreach my $repo (@{$product->{repos}})
        {
            $self->_updateRepositories($repo);
            $self->_updateProductCatalogs($product, $repo);
        }
    }
}

1;
