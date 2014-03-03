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

    $self->{API} = SMT::SCCAPI->new(vblevel => $vblevel,
                                    log     => $LOG,
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
        open( my $fh, '<', $self->{FROMDIR}."/products.json" ) and do
        {
            my $json_text   = <$fh>;
            $input = JSON::decode_json( $json_text );
            close $fh;
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
        open( my $fh, '>', $self->{TODIR}."/products.json") or do
        {
            printLog($self->{LOG}, $self->{VBLEVEL}, LOG_ERROR, "Cannot open file: $!");
            return 1;
        }
        my $json_text = JSON::encode_json($input);
        print $fh, "$json_text";
        close $fh;
        return 0;
    }
    else
    {
        $ret = $self->_updateProducts($input);
        return $ret;
    }
}

###############################################################################
###############################################################################
###############################################################################
###############################################################################

sub _updateProducts
{
    my $self = shift;
    my $json = shift;

    if(!defined $self->{DBH})
    {
        printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "Cannot connect to database.");
        return 1;
    }
    my $query_products = "SELECT PRODUCTDATAID, PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER
                            FROM PRODUCTS
                           WHERE SRC='S'";
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $query_products");
    my $allProducts = $self->{DBH}->selectall_hashref($stm, ['PRODUCTDATAID']);

    my $query_repositories = "SELECT ID, CATALOGID, NAME, TARGET FROM Catalogs WHERE SRC = 'S'";
    printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $query_catalogs");
    my $allRepositories = $self->{DBH}->selectall_hashref($stm, ['CATALOGID']);


    foreach my $product (@$json)
    {
        my $statement = "";
        if (exists $allProducts-{$product->{product_id}})
        {
            $statement = sprintf("UPDATE Products
                                     SET PRODUCT = %s,
                                         VERSION = %s,
                                         REL = %s,
                                         ARCH = %s,
                                         PRODUCTLOWER = %s,
                                         VERSIONLOWER = %s,
                                         RELLOWER = %s,
                                         ARCHLOWER = %s,
                                         FRIENDLY = %s,
                                         PRODUCT_LIST = %s,
                                         PRODUCT_CLASS = %s
                                   WHERE PRODUCTDATAID = %s",
                                   $self-{DBH}->quote($product->{name}),
                                   $self-{DBH}->quote($product->{version}),
                                   $self-{DBH}->quote($product->{rel}),
                                   $self-{DBH}->quote($product->{arch}),
                                   $self-{DBH}->quote(lc($product->{name})),
                                   $self-{DBH}->quote(lc($product->{version})),
                                   $self-{DBH}->quote(lc($product->{rel})),
                                   $self-{DBH}->quote(lc($product->{arch})),
                                   $self-{DBH}->quote($product->{friendly}),
                                   $self-{DBH}->quote(($product->{product_list}?'Y':'N')),
                                   $self-{DBH}->quote($product->{product_class}),
                                   $self-{DBH}->quote($product->{product_id})
                         );
        }
        else
        {
            $statement = sprintf("INSERT INTO Products (PRODUCT, VERSION, REL, ARCH,
                                                        PRODUCTLOWER, VERSIONLOWER, RELLOWER, ARCHLOWER,
                                                        FRIENDLY, PRODUCT_LIST, PRODUCT_CLASS, PRODUCTDATAID)
                                  VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)",
                                   $self-{DBH}->quote($product->{name}),
                                   $self-{DBH}->quote($product->{version}),
                                   $self-{DBH}->quote($product->{rel}),
                                   $self-{DBH}->quote($product->{arch}),
                                   $self-{DBH}->quote(lc($product->{name})),
                                   $self-{DBH}->quote(lc($product->{version})),
                                   $self-{DBH}->quote(lc($product->{rel})),
                                   $self-{DBH}->quote(lc($product->{arch})),
                                   $self-{DBH}->quote($product->{friendly}),
                                   $self-{DBH}->quote(($product->{product_list}?'Y':'N')),
                                   $self-{DBH}->quote($product->{product_class}),
                                   $self-{DBH}->quote($product->{product_id}));
        }
        printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
        eval {
            $self->{DBH}->do($statement);
        };
        if($@)
        {
            printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
        }

        foreach my $repo (@{$product->{repos}})
        {
            my $localpath = "RPMMD/".$repo->{name};
            if (grep $_ == 'nu', @{$repo->{flags}})
            {
                $localpath = $repo->{name}."/".$repo->{distro_target};
            }
            # FIXME: add sles10sp1 ATI and nVidia special
            my $exthost = URI->new($repo->{url});
            $exthost->path("");
            $exthost->fragment("");
            $exthost->query("");

            if (exists $allRepositories-{$repo->{repo_id}})
            {
                $statement = sprintf("UPDATE Catalogs
                                         SET NAME = %s,
                                             DESCRIPTION = %s,
                                             TARGET = %s,
                                             LOCALPATH = %s,
                                             EXTHOST = %s,
                                             EXTURL = %s,
                                             CATALOGTYPE = %s
                                       WHERE CATALOGID = %s",
                                     $self-{DBH}->quote($repo->{name}),
                                     $self-{DBH}->quote($repo->{description}),
                                     $self-{DBH}->quote($repo->{distro_target}),
                                     $self-{DBH}->quote($localpath),
                                     $self-{DBH}->quote($exthost),
                                     $self-{DBH}->quote($repo->{url}),
                                     $self-{DBH}->quote('nu'),
                                     $self-{DBH}->quote($repo->{repo_id})
                                    );
            }
            else
            {
                $statement = sprintf("INSERT INTO Catalogs (NAME, DESCRIPTION, TARGET, LOCALPATH,
                                                            EXTHOST, EXTURL, CATALOGTYPE, CATALOGID, SRC)
                                      VALUES (%s, %s, %s, %s, %s, %s, %s, %s, 'S')",
                                     $self-{DBH}->quote($repo->{name}),
                                     $self-{DBH}->quote($repo->{description}),
                                     $self-{DBH}->quote($repo->{distro_target}),
                                     $self-{DBH}->quote($localpath),
                                     $self-{DBH}->quote($exthost),
                                     $self-{DBH}->quote($repo->{url}),
                                     $self-{DBH}->quote('nu'),
                                     $self-{DBH}->quote($repo->{repo_id})
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

            $statement = sprintf("DELETE FROM ProductCatalogs
                                  WHERE PRODUCTDATAID = %s
                                    AND CATALOGID = %s",
                                 $self-{DBH}->quote($product->{product_id}),
                                 $self-{DBH}->quote($repo->{repo_id})
                         );
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
            eval {
                $self->{DBH}->do($statement);
            };
            if($@)
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
            }
            my $optional = ((grep $_ == 'optional', @{$repo->{flags}})?"Y":"N")

            $statement = sprintf("INSERT INTO ProductCatalogs (PRODUCTDATAID, CATALOGID, OPTIONAL, SRC)
                                  VALUES (%s, %s, %s, 'S')",
                                 $self-{DBH}->quote($product->{product_id}),
                                 $self-{DBH}->quote($repo->{repo_id}),
                                 $self-{DBH}->quote($optional));
            printLog($self->{LOG}, $self->vblevel(), LOG_DEBUG, "STATEMENT: $statement");
            eval {
                $self->{DBH}->do($statement);
            };
            if($@)
            {
                printLog($self->{LOG}, $self->vblevel(), LOG_ERROR, "$@");
            }
        }
    }
}

1;
