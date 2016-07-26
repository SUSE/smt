package SMT::Rest::SCCAPIv3;

require SMT::Rest::SCCAPIv2;
@ISA = qw(SMT::Rest::SCCAPIv2);

use strict;
use Apache2::Const -compile => qw(:log OK SERVER_ERROR HTTP_NO_CONTENT AUTH_REQUIRED FORBIDDEN HTTP_UNPROCESSABLE_ENTITY HTTP_UNAUTHORIZED);

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
               p.SHORTNAME shortname,
               p.RELEASE_STAGE release_stage,
               1 free,
               p.PRODUCT_TYPE product_type,
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
    my $code = Apache2::Const::OK;
    my $errmsg = "";
    eval
    {
        my $baseURL = $self->cfg()->val('LOCAL', 'url');
        $baseURL =~ s/\/*$//;

        my $new_ids = [];
        $result = $self->dbh()->selectall_hashref($sql, 'id');

        if (scalar(keys %{$result}) == 0)
        {
            $code = Apache2::Const::HTTP_UNPROCESSABLE_ENTITY;
            $errmsg = "The requested product is not activated on this system.";
            return; # goes out of the eval
        }

        foreach my $pdid (keys %{$result})
        {
            $result->{$pdid}->{extensions} = [];
            $result->{$pdid}->{id} = int($result->{$pdid}->{id});
            $result->{$pdid}->{free} = ($result->{$pdid}->{free} eq "0"?JSON::false:JSON::true);
            $result->{$pdid}->{available} = ($result->{$pdid}->{available} eq "0"?JSON::false:JSON::true);
            $result->{$pdid}->{repositories} = $self->_repositories_for_product($baseURL, $result->{$pdid}->{id});
            foreach my $ext ( values %{$self->_extensions_for_products([$result->{$pdid}->{id}])})
            {
                push @{$result->{$pdid}->{extensions}}, $ext;
            }
        }
    };
    if ($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }
    return ($code, $errmsg) if($code != Apache2::Const::OK);

    # log->info is limited in strlen. If you want to see all, you need to print to STDERR
    #print STDERR "PRODUCTS: ".Data::Dumper->Dump([$result->{$req_pdid}])."\n";

    return (($result?Apache2::Const::OK:Apache2::Const::HTTP_UNPROCESSABLE_ENTITY), $result->{$req_pdid});
}

sub get_subscriptions_products
{
    my $self = shift || return (undef, undef);
    my $result = {};
    my $sql = "";
    my $productids = [];
    # We are sure, that user is a system GUID
    my $guid = $self->user();
    my $product_class = undef;
    my $token = $self->get_header("Authorization");
    if($token)
    {
        my ($key, $value) = split(/=/, $token, 2);
        if ($key = "Token token")
        {
            my $sub = SMT::Utils::lookupSubscriptionByRegcode($self->dbh(), $value, $self->request());
            $product_class = $sub->{'PRODUCT_CLASS'};
        }
        if(!$product_class)
        {
            # we got a token but it seems to be invalid
            return (Apache2::Const::HTTP_UNAUTHORIZED, "Invalid registration code");
        }
    }
    my $args = $self->parse_args();

    if(!$args || scalar(keys %{$args}) == 0)
    {
        # try to read from body
        $args = JSON::decode_json($self->read_post());
    }
    $self->request()->log->info(Data::Dumper->Dump([$args]));
    my $req_pdid = undef;
    if (exists $args->{identifier} && exists $args->{version} && exists $args->{arch})
    {
        my $release = ((exists $args->{release_type})?$args->{release_type}:"");
        $req_pdid = SMT::Utils::lookupProductIdByName($self->dbh(), $args->{identifier},
                                                      $args->{version}, $release,
                                                      $args->{arch}, $self->request());
    }
    elsif (!$token)
    {
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "Either token or product required");
    }

    $sql ="SELECT p.id id,
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
               p.SHORTNAME shortname,
               p.RELEASE_STAGE release_stage,
               1 free,
               p.PRODUCT_TYPE product_type,
               (CASE WHEN (SELECT c.DOMIRROR
                             FROM ProductCatalogs pc
                             JOIN Catalogs c ON pc.CATALOGID = c.ID
                            WHERE pc.PRODUCTID = p.ID
                              AND c.DOMIRROR = 'N'
                              AND pc.OPTIONAL = 'N'
                         GROUP BY c.DOMIRROR) = 'N'
                THEN 0 ELSE 1 END ) available
           FROM Products p
          WHERE 1 = 1 ";
    if($req_pdid) {
        $sql .= sprintf(" AND p.ID = %s", $self->dbh()->quote($req_pdid));
    }
    if($product_class) {
        $sql .= sprintf(" AND p.product_class = %s", $self->dbh()->quote($product_class));
    }
    $self->request()->log->info("STATEMENT: $sql");
    my $code = Apache2::Const::OK;
    my $errmsg = "";
    eval
    {
        my $baseURL = $self->cfg()->val('LOCAL', 'url');
        $baseURL =~ s/\/*$//;

        my $new_ids = [];
        $result = $self->dbh()->selectall_hashref($sql, 'id');

        if (scalar(keys %{$result}) == 0)
        {
            $code = Apache2::Const::HTTP_UNPROCESSABLE_ENTITY;
            $errmsg = "Unable to find the requested product.";
            return; # goes out of the eval
        }

        foreach my $pdid (keys %{$result})
        {
            $result->{$pdid}->{extensions} = [];
            $result->{$pdid}->{id} = int($result->{$pdid}->{id});
            $result->{$pdid}->{free} = ($result->{$pdid}->{free} eq "0"?JSON::false:JSON::true);
            $result->{$pdid}->{available} = ($result->{$pdid}->{available} eq "0"?JSON::false:JSON::true);
            $result->{$pdid}->{repositories} = $self->_repositories_for_product($baseURL, $result->{$pdid}->{id}, 1);
            foreach my $ext ( values %{$self->_extensions_for_products([$result->{$pdid}->{id}], 1)})
            {
                push @{$result->{$pdid}->{extensions}}, $ext;
            }
        }
    };
    if ($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }
    return ($code, $errmsg) if($code != Apache2::Const::OK);

    # log->info is limited in strlen. If you want to see all, you need to print to STDERR
    #print STDERR "PRODUCTS: ".Data::Dumper->Dump([values %{$result}])."\n";

    return (($result?Apache2::Const::OK:Apache2::Const::HTTP_UNPROCESSABLE_ENTITY), [values %{$result}]);
}

################ PRIVATE ####################

sub _extensions_for_products
{
    my $self       = shift || return {};
    my $productids = shift || return {};
    my $includeRepoAuth = shift || 0;
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
               e.SHORTNAME shortname,
               e.RELEASE_STAGE release_stage,
               1 free,
               e.PRODUCT_TYPE product_type,
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
            $result->{$pdid}->{repositories} = $self->_repositories_for_product($baseURL, $result->{$pdid}->{id}, $includeRepoAuth);
            foreach my $ext ( values %{$self->_extensions_for_products([$result->{$pdid}->{id}], $includeRepoAuth)})
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
               p.SHORTNAME shortname,
               p.RELEASE_STAGE release_stage,
               1 free,
               p.PRODUCT_TYPE product_type,
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
            $product->{repositories} = $self->_repositories_for_product($baseURL, $product->{id});
            $result = $product;
        }
    };
    if ($@)
    {
        $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
    }
    return $result;
}

sub _repositories_for_product
{
    my $self      = shift || return ([], []);
    my $baseURL   = shift || return ([], []);
    my $productid = shift || return ([], []);
    my $includeRepoAuth = shift || 0;
    my $installerUpdatesOnly = shift || 0;
    my $enabled_repositories = [];
    my $repositories = [];
    my $credStr = "";
    if ($includeRepoAuth)
    {
        my $localId = $self->get_local_id();
        if($localId)
        {
            $credStr = "?credentials=$localId";
        }
    }
    my $sql = sprintf("
        select c.id,
               c.name,
               c.target distro_target,
               c.description,
               CONCAT(%s, '/repo/', c.localpath, %s) url,
               c.autorefresh,
               pc.OPTIONAL,
               pc.installer_updates
          from ProductCatalogs pc
          join Catalogs c ON pc.catalogid = c.id
         where pc.productid = %s
         ",
         $self->dbh()->quote($baseURL),
         $self->dbh()->quote($credStr),
         $self->dbh()->quote($productid));
    if($installerUpdatesOnly)
    {
        $sql .= " and pc.installer_updates = 'Y'";
    }
    $self->request()->log->info("STATEMENT: $sql");
    eval
    {
        foreach my $repo (@{$self->dbh()->selectall_arrayref($sql, {Slice => {}})})
        {
            $repo->{autorefresh} = (($repo->{autorefresh} eq 'Y')?JSON::true:JSON::false);
            $repo->{enabled} = (($repo->{OPTIONAL} eq 'N')?JSON::true:JSON::false);
            $repo->{installer_updates} = (($repo->{installer_updates} eq 'Y')?JSON::true:JSON::false);
            delete $repo->{OPTIONAL};
            push @{$repositories}, $repo;
        }
    };
    if ($@)
    {
        $self->request()->log_error("DBERROR: $@ ".$self->dbh()->errstr);
    }
    return $repositories;
}


1;
