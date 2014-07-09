package SMT::Rest::SCCAPIv2;

require SMT::Rest::SCCAPIv1;
@ISA = qw(SMT::Rest::SCCAPIv1);

use strict;
use Apache2::Const -compile => qw(:log OK SERVER_ERROR HTTP_NO_CONTENT AUTH_REQUIRED FORBIDDEN HTTP_UNPROCESSABLE_ENTITY);

use JSON;

use SMT::Utils;
use SMT::Client;
use SMT::Registration;


sub new
{
    my($class, $r) = @_;
    my $self = $class->SUPER::new($r);

    return $self;
}

sub systems_handler()
{
    my $self = shift;
    my ($code, $data) = (undef, undef);

    ($code, $data) = $self->SUPER::systems_handler();
    if (!defined $code && !defined $data)
    {
        my $path = $self->sub_path();

        if     ( $self->request()->method() =~ /^GET$/i )
        {
            if     ( $path =~ /^systems\/activations\/?$/ ) { return $self->get_activations(); }
        }
        elsif ( $self->request()->method() =~ /^POST$/i )
        {
        }
        elsif ( $self->request()->method() =~ /^PUT$/i || $self->request()->method() =~ /^PATCH$/i)
        {
            if     ( $path =~ /^systems\/products\/?$/ ) { return $self->update_product(); }
        }
        elsif ( $self->request()->method() =~ /^DELETE$/i )
        {
        }
     }
     return ($code, $data);
}

sub get_extensions
{
    my $self = shift || return (undef, undef);
    my $result = {};
    my $sql = "";
    my $productids = [];
    # We are sure, that user is a system GUID
    my $guid = $self->user();

    my $args = $self->parse_args();
    if(!$args || scalar(keys %{$args}) == 0)
    {
        # try to read from body
        $args = JSON::decode_json($self->read_post());
    }
    $self->request()->log->info(Data::Dumper->Dump([$args]));
    if (!exists $args->{identifier} || !exists $args->{version} || !exists $args->{arch})
    {
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "No product specified");
    }

    my $release = ((exists $args->{release_type})?$args->{release_type}:"");
    my $req_pdid = SMT::Utils::lookupProductIdByName($self->dbh(), $args->{identifier},
                                                     $args->{version}, $release,
                                                     $args->{arch}, $self->request());

    $sql = sprintf(
        "SELECT p.id id,
               p.FRIENDLY friendly_name,
               p.FRIENDLY name,
               p.PRODUCT identifier,
               p.FORMER_IDENTIFIER former_identifier,
               p.DESCRIPTION description,
               p.VERSION version,
               p.REL release_type,
               p.ARCH arch,
               p.PRODUCT_CLASS product_class,
               p.CPE cpe,
               p.EULA_URL eula_url,
               1 free,
               (CASE WHEN (SELECT c.DOMIRROR
                             FROM ProductCatalogs pc
                             JOIN Catalogs c ON pc.CATALOGID = c.ID
                            WHERE pc.PRODUCTID = p.ID
                              AND c.DOMIRROR = 'N'
                              AND pc.OPTIONAL = 'N'
                         GROUP BY c.DOMIRROR) = 'N'
                THEN 0 ELSE 1 END ) available
           FROM Registration r
           JOIN Products p ON r.PRODUCTID = p.ID
          WHERE r.GUID = %s
            AND r.PRODUCTID = %s
        ", $self->dbh()->quote($guid), $self->dbh()->quote($req_pdid));

    $self->request()->log->info("STATEMENT: $sql");
    eval
    {
        my $baseURL = $self->cfg()->val('LOCAL', 'url');
        $baseURL =~ s/\/*$//;

        my $new_ids = [];
        $result = $self->dbh()->selectall_hashref($sql, 'id');
        if (scalar(keys %{$result}) == 0)
        {
            $self->request()->log_error("The requested product is not activated on this system.");
            return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "The requested product is not activated on this system.");
        }

        foreach my $pdid (keys %{$result})
        {
            $result->{$pdid}->{extensions} = [];
            $result->{$pdid}->{id} = int($result->{$pdid}->{id});
            $result->{$pdid}->{free} = ($result->{$pdid}->{free} eq "0"?JSON::false:JSON::true);
            $result->{$pdid}->{available} = ($result->{$pdid}->{available} eq "0"?JSON::false:JSON::true);
            ($result->{$pdid}->{enabled_repositories}, $result->{$pdid}->{repositories}) =
                $self->_repositories_for_product($baseURL, $result->{$pdid}->{id});
            foreach my $ext ( values %{$self->_extensions_for_products([$result->{$pdid}->{id}])})
            {
                push @{$result->{$pdid}->{extensions}}, $ext;
            }
        }
    };
    if ($@)
    {
        $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
    }

    # log->info is limited in strlen. If you want to see all, you need to print to STDERR
    print STDERR "PRODUCTS: ".Data::Dumper->Dump([$result->{$req_pdid}])."\n";

    return (($result?Apache2::Const::OK:Apache2::Const::HTTP_UNPROCESSABLE_ENTITY), $result->{$req_pdid});
}

#
# announce a system (V2). This call create a system object in the DB
# and return system username and password to the client.
# all params are optional.
#
# QUESTION: no chance to check duplicate clients?
#           Every client should call this only once?
#
sub products
{
    my $self = shift || return (undef, undef);
    my $c    = JSON::decode_json($self->read_post());
    my $result = {};
    my $cnt = 0;

    # We are sure, that user is a system GUID
    my $guid = $self->user();
    my $token = "";
    my $email = "";
    my $statement = "";

    if ( exists $c->{token} && $c->{token})
    {
        # Token in SMT is not a required parameter
        if(not SMT::Utils::lookupSubscriptionByRegcode($self->dbh(), $c->{token}, $self->request()))
        {
            $token = $c->{token};
        }
        else
        {
            # FIXME: should we abort with an error? SMT do not need a regcode,
            #        but if we get one and it is wrong?
            ;
        }
    }

    if ( ! (exists $c->{identifier} && $c->{identifier}))
    {
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "Missing required parameter: identifier");
    }

    if ( ! (exists $c->{version} && $c->{version}))
    {
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "Missing required parameter: version");
    }

    if ( ! (exists $c->{arch} && $c->{arch}))
    {
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "Missing required parameter: arch");
    }

    if ( ! (exists $c->{release_type}))
    {
        $c->{release_type} = undef;
    }

    if ( exists $c->{email} && $c->{email})
    {
        $email = $c->{email};
    }

    my $productId = SMT::Utils::lookupProductIdByName($self->dbh(), $c->{identifier}, $c->{version},
                                                      $c->{release_type}, $c->{arch});
    if(not $productId)
    {
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "No valid product found");
    }

    #
    # insert registration
    #
    my $existingregs = SMT::Utils::lookupRegistrationByGUID($self->dbh(), $guid, $self->request());
    if(exists $existingregs->{$productId} && $existingregs->{$productId})
    {
        $statement = sprintf("UPDATE Registration SET REGDATE=%s WHERE GUID=%s AND PRODUCTID=%s",
                             $self->dbh()->quote( SMT::Utils::getDBTimestamp()),
                             $self->dbh()->quote($guid),
                             $self->dbh()->quote($productId));
    }
    else
    {
        $statement = sprintf("INSERT INTO Registration (GUID, PRODUCTID, REGDATE) VALUES (%s, %s, %s)",
                             $self->dbh()->quote($guid),
                             $self->dbh()->quote($productId),
                             $self->dbh()->quote( SMT::Utils::getDBTimestamp()));
    }
    $self->request()->log->info("STATEMENT: $statement");
    eval
    {
        $self->dbh()->do($statement);
    };
    if ($@)
    {
        $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
    }
    #
    # insert product info into MachineData
    #
    $statement = sprintf("DELETE from MachineData where GUID=%s AND KEYNAME LIKE %s",
                         $self->dbh()->quote($guid),
                         $self->dbh()->quote("product-%-$productId"));
    eval {
        $cnt = $self->dbh()->do($statement);
        $self->request()->log->info("STATEMENT: $statement  Affected rows: $cnt");
    };
    if($@)
    {
        $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
    }
    $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                         $self->dbh()->quote($guid),
                         $self->dbh()->quote("product-name-$productId"),
                         $self->dbh()->quote($c->{identifier}));
    $self->request()->log->info("STATEMENT: $statement");
    eval {
        $cnt = $self->dbh()->do($statement);
    };
    if($@)
    {
        $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
    }
    $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                         $self->dbh()->quote($guid),
                         $self->dbh()->quote("product-version-$productId"),
                         $self->dbh()->quote($c->{version}));
    $self->request()->log->info("STATEMENT: $statement");
    eval {
        $cnt = $self->dbh()->do($statement);
    };
    if($@)
    {
        $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
    }
    $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                         $self->dbh()->quote($guid),
                         $self->dbh()->quote("product-arch-$productId"),
                         $self->dbh()->quote($c->{arch}));
    $self->request()->log->info("STATEMENT: $statement");
    eval {
        $cnt = $self->dbh()->do($statement);
    };
    if($@)
    {
        $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
    }
    $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                         $self->dbh()->quote($guid),
                         $self->dbh()->quote("product-rel-$productId"),
                         $self->dbh()->quote($c->{release_type}));
    $self->request()->log->info("STATEMENT: $statement");
    eval {
        $cnt = $self->dbh()->do($statement);
    };
    if($@)
    {
        $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
    }
    if ( exists $c->{token} && $c->{token})
    {
        # if we got a tokem, store it for later transfer to SCC.
        $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                            $self->dbh()->quote($guid),
                            $self->dbh()->quote("product-token-$productId"),
                            $self->dbh()->quote($c->{token}));
        $self->request()->log->info("STATEMENT: $statement");
        eval {
            $cnt = $self->dbh()->do($statement);
        };
        if($@)
        {
            $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
        }
    }


    #
    # lookup the Clients target
    #
    my $target = SMT::Utils::lookupTargetForClient($self->dbh(), $guid, $self->request());

    #
    # find Catalogs
    #
    $existingregs = SMT::Utils::lookupRegistrationByGUID($self->dbh(), $guid, $self->request());
    my @pidarr = keys %{$existingregs};
    my $catalogs = SMT::Registration::findCatalogs($self->request(), $self->dbh(), $target, \@pidarr);

    if ( (keys %{$catalogs}) == 0)
    {
        $self->request()->log->info("No repositories found");
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "No repositories found");
    }

    # TODO: get status - from SMT?

    # return result
    return $self->_registrationResult($productId);
}

sub update_product
{
    my $self = shift || return (undef, undef);
    my $args = JSON::decode_json($self->read_post());
    my $product_classes = {};
    my $old_pdid = undef;

    if (!exists $args->{identifier} || !exists $args->{version} || !exists $args->{arch})
    {
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "No product specified");
    }

    # We are sure, that user is a system GUID
    my $guid = $self->user();

    my $sql = sprintf("SELECT p.id, p.PRODUCT_CLASS
                         FROM Products p
                         JOIN Registration r ON r.PRODUCTID = p.ID
                        WHERE r.GUID = %s
                          AND p.PRODUCT_CLASS is not NULL
                      ", $self->dbh()->quote($guid));
    $self->request()->log->info("STATEMENT: $sql");
    eval {
        $product_classes = $self->dbh()->selectall_hashref($sql, "PRODUCT_CLASS");
    };
    if($@)
    {
        $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
    }

    my $release = ((exists $args->{release_type})?$args->{release_type}:"");
    my $req_pdid = SMT::Utils::lookupProductIdByName($self->dbh(), $args->{identifier},
                                                     $args->{version}, $release,
                                                     $args->{arch}, $self->request());
    $sql = sprintf("SELECT PRODUCT_CLASS FROM Products WHERE ID = %s", $self->dbh()->quote($req_pdid));
    $self->request()->log->info("STATEMENT: $sql");
    eval {
        my $new_class = $self->dbh()->selectcol_arrayref($sql)->[0];
        if(not exists $product_classes->{$new_class})
        {
            return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY,
                    "No installed product with requested update product found");
        }
        else
        {
            $old_pdid = $product_classes->{$new_class}->{ID};
        }
    };
    if($@)
    {
        $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
    }
    if($old_pdid && $req_pdid)
    {
        $sql = sprintf("UPDATE Registration
                           SET PRODUCTID = %s
                         WHERE GUID = %s
                           AND PRODUCTID = %s",
                       $self->dbh()->quote($req_pdid),
                       $self->dbh()->quote($guid),
                       $self->dbh()->quote($old_pdid));
        $self->request()->log->info("STATEMENT: $sql");
        eval {
            $self->dbh()->do($sql);
        };
        if($@)
        {
            $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
        }
    }
    return $self->_registrationResult($req_pdid);
}

sub get_activations
{
    my $self = shift || return (undef, undef);
    my $activations = [];

    # We are sure, that user is a system GUID
    my $guid = $self->user();

    my $sql = "SELECT c.ID system_id,
                      s.REGCODE regcode,
                      s.SUBTYPE type,
                      s.SUBSTATUS status,
                      DATE_FORMAT(s.SUBSTARTDATE, '%Y-%m-%dT%TZ') starts_at,
                      DATE_FORMAT(s.SUBENDDATE, '%Y-%m-%dT%TZ') expires_at,
                      r.PRODUCTID product_id
                 FROM Registration r
                 JOIN Clients c ON r.GUID = c.GUID
            LEFT JOIN ClientSubscriptions cs ON r.GUID = cs.GUID
            LEFT JOIN Subscriptions s on cs.SUBID = s.SUBID
                WHERE r.GUID = ".$self->dbh()->quote($guid);

    $self->request()->log->info("STATEMENT: $sql");
    eval
    {
        my $baseURL = $self->cfg()->val('LOCAL', 'url');
        $baseURL =~ s/\/*$//;

        my $res = $self->dbh()->selectall_hashref($sql, 'product_id');
        if (scalar(keys %{$res}) == 0)
        {
            $self->request()->log_error("No products activated on this system.");
            return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "No products activated on this system.");
        }

        foreach my $activation (values %{$res})
        {
            my($dummy, $service) = $self->_registrationResult($activation->{product_id});
            delete $activation->{product_id};
            $activation->{service} = $service;
            push @{$activations}, $activation;
        }
    };
    if ($@)
    {
        $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
    }
    # log->info is limited in strlen. If you want to see all, you need to print to STDERR
    print STDERR "ACTIVATIONS: ".Data::Dumper->Dump([$activations])."\n";

    return (Apache2::Const::OK, $activations);
}

################ PRIVATE ####################

sub _extensions_for_products
{
    my $self       = shift || return {};
    my $productids = shift || return {};
    my $result = {};

    if (scalar(@{$productids}) == 0)
    {
        $self->request()->log->info("no more extensions");
        return {};
    }
    foreach (@{$productids})
    {
        $_ = $self->dbh()->quote($_);
    }
    my $sql = sprintf("
        SELECT e.id id,
               e.FRIENDLY friendly_name,
               e.FRIENDLY name,
               e.PRODUCT identifier,
               e.FORMER_IDENTIFIER former_identifier,
               e.DESCRIPTION description,
               e.VERSION version,
               e.REL release_type,
               e.ARCH arch,
               e.PRODUCT_CLASS product_class,
               e.CPE cpe,
               e.EULA_URL eula_url,
               1 free,
               (CASE WHEN (SELECT c.DOMIRROR
                             FROM ProductCatalogs pc
                             JOIN Catalogs c ON pc.CATALOGID = c.ID
                            WHERE pc.PRODUCTID = e.ID
                              AND c.DOMIRROR = 'N'
                              AND pc.OPTIONAL = 'N'
                         GROUP BY c.DOMIRROR) = 'N'
                THEN 0 ELSE 1 END ) available
          FROM Products p
          JOIN ProductExtensions pe ON p.ID = pe.PRODUCTID
          JOIN Products e ON pe.EXTENSIONID = e.ID
          WHERE p.ID in (%s)
          AND e.PRODUCT_LIST = 'Y'
    ", join(',', @{$productids}));
    $self->request()->log->info("STATEMENT: $sql");
    eval
    {
        my $baseURL = $self->cfg()->val('LOCAL', 'url');
        $baseURL =~ s/\/*$//;

        my $new_ids = [];
        $result = $self->dbh()->selectall_hashref($sql, 'id');
        foreach my $pdid (keys %{$result})
        {
            $result->{$pdid}->{extensions} = [];
            $result->{$pdid}->{free} = ($result->{$pdid}->{free} eq "0"?JSON::false:JSON::true);
            $result->{$pdid}->{available} = ($result->{$pdid}->{available} eq "0"?JSON::false:JSON::true);
            $result->{$pdid}->{id} = int($result->{$pdid}->{id});
            ($result->{$pdid}->{enabled_repositories}, $result->{$pdid}->{repositories}) =
                $self->_repositories_for_product($baseURL, $result->{$pdid}->{id});
            foreach my $ext ( values %{$self->_extensions_for_products([$result->{$pdid}->{id}])})
            {
                push @{$result->{$pdid}->{extensions}}, $ext;
            }
        }
    };
    if ($@)
    {
        $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
    }
    return $result;
}

sub _registrationResult
{
    my $self = shift || return (undef, undef);
    my $product_id  = shift || undef;

    my $LocalNUUrl = $self->cfg()->val('LOCAL', 'url');
    my $LocalBasePath = $self->cfg()->val('LOCAL', 'MirrorTo');
    my $aliasChange = $self->cfg()->val('NU', 'changeAlias');
    if(defined $aliasChange && $aliasChange eq "true")
    {
        $aliasChange = 1;
    }
    else
    {
        $aliasChange = 0;
    }

    $LocalNUUrl =~ s/\s*$//;
    $LocalNUUrl =~ s/\/*$//;
    if(! $LocalNUUrl || $LocalNUUrl !~ /^http/)
    {
        $self->request()->log_error("Invalid url parameter in smt.conf. Please fix the url parameter in the [LOCAL] section.");
        return (Apache2::Const::SERVER_ERROR, "SMT server is missconfigured. Please contact your administrator.");
    }
    my $localID = "SMT-".$LocalNUUrl;
    $localID =~ s/:*\/+/_/g;
    $localID =~ s/\./_/g;
    $localID =~ s/_$//;

    my $p = $self->_getProduct($product_id);

    my $response = {
        'id' => 1,
        'name' =>  $localID,
        'url'  =>  "$LocalNUUrl?credentials=$localID",
        'product' => $p
    };
    return (Apache2::Const::OK, $response);
}

sub _getProduct
{
    my $self = shift || return {};
    my $product_id  = shift || return {};

    my $sql = sprintf("
        SELECT p.id id,
               p.FRIENDLY friendly_name,
               p.FRIENDLY name,
               p.PRODUCT identifier,
               p.FORMER_IDENTIFIER former_identifier,
               p.DESCRIPTION description,
               p.VERSION version,
               p.REL release_type,
               p.ARCH arch,
               p.PRODUCT_CLASS product_class,
               p.CPE cpe,
               p.EULA_URL eula_url,
               1 free,
               (CASE WHEN (SELECT c.DOMIRROR
                             FROM ProductCatalogs pc
                             JOIN Catalogs c ON pc.CATALOGID = c.ID
                            WHERE pc.PRODUCTID = p.ID
                              AND c.DOMIRROR = 'N'
                              AND pc.OPTIONAL = 'N'
                         GROUP BY c.DOMIRROR) = 'N'
                THEN 0 ELSE 1 END ) available
          FROM Products p
         WHERE p.ID = %s
    ", $self->dbh()->quote($product_id));
    $self->request()->log->info("STATEMENT: $sql");

    my $result = {};
    eval
    {
        my $baseURL = $self->cfg()->val('LOCAL', 'url');
        $baseURL =~ s/\/*$//;

        my $new_ids = [];
        my $res = $self->dbh()->selectall_hashref($sql, 'id');

        # the result should contain maximal 1 product
        foreach my $product (values %{$res})
        {
            $product->{free} = ($product->{free} eq "0"?JSON::false:JSON::true);
            $product->{available} = ($product->{available} eq "0"?JSON::false:JSON::true);
            $product->{id} = int($product->{id});
            ($product->{enabled_repositories}, $product->{repositories}) =
                $self->_repositories_for_product($baseURL, $product->{id});
            $result = $product;
        }
    };
    if ($@)
    {
        $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
    }
    return $result;
}

1;
