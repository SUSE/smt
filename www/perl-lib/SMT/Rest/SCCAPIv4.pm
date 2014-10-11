package SMT::Rest::SCCAPIv4;

require SMT::Rest::Base;
@ISA = qw(SMT::Rest::Base);

use strict;
use Apache2::Const -compile => qw(:log OK SERVER_ERROR HTTP_NO_CONTENT AUTH_REQUIRED FORBIDDEN HTTP_UNPROCESSABLE_ENTITY);

use JSON;

use SMT::Utils;
use SMT::Client;
use SMT::Registration;

=head1 NAME

SMT::Rest::SCCAPIv4 - SCC API v4

=head1 SYNOPSIS

  use SMT::Rest::SCCAPIv4;

=head1 DESCRIPTION

SCC API v4

=head1 METHODS

=over 4

=item new

=cut

sub new
{
    my($class, $r) = @_;
    my $self = $class->SUPER::new($r);

    return $self;
}

=item handler

=cut

sub handler
{
    my $self = shift;

    my $path = $self->sub_path();
    my $code = Apache2::Const::SERVER_ERROR;
    my $data = "";
    my $cfg = undef;

    if ( $path =~ qr{^subscriptions?} )
    {
        $self->request()->log->info("call subscriptions handler");
        ($code, $data) = $self->subscriptions_handler();
    }
    elsif  ( $path =~ qr{^systems?})
    {
        $self->request()->log->info("call systems handler");
        ($code, $data) = $self->systems_handler();
    }

    if (! defined $code || !($code == Apache2::Const::OK || $code == Apache2::Const::HTTP_NO_CONTENT))
    {
        return $self->respond_with_error($code, $data);
    }
    elsif ($code != Apache2::Const::HTTP_NO_CONTENT)
    {
        $self->request()->content_type('application/json');
        $self->request()->err_headers_out->add('Cache-Control' => "no-cache, public, must-revalidate");
        $self->request()->err_headers_out->add('Pragma' => "no-cache");
        print encode_json($data);
    }

    # return a 200 response
    return $code;
}

=item systems_handler

Requires system authentication

=cut

sub systems_handler()
{
    my $self = shift;

    # systems handler requires authentication
    return Apache2::Const::AUTH_REQUIRED unless ( defined $self->user()  &&  $self->user() ne '' );

    my ($status, $password) = $self->request()->get_basic_auth_pw;
    return $self->respond_with_error($status, "unauthorized") unless $status == Apache2::Const::OK;

    # to be sure that the authentication happens with GUID/SECRET and not with
    # mirror credentails
    my $client = SMT::Client->new({ 'dbh' => $self->dbh() });
    my $auth = $client->authenticateByGUIDAndSecret($self->user(), $password);
    if ( keys %{$auth} != 1 )
    {
        $self->request()->log->error("No client authentication provided");
        return $self->respond_with_error(Apache2::Const::FORBIDDEN, "No client authentication provided") ;
    }

    my $update_last_contact = $self->update_last_contact();
    if ( $update_last_contact )
    {
        $self->request()->log->info(sprintf("Request from client (%s). Updated its last contact timestamp.",
                                            $self->user()) );
    }
    else
    {
        $self->request()->log->info(sprintf("Request from client (%s). Could not updated its last contact timestamp.",
                                            $self->user()) );
    }
    my $path = $self->sub_path();

    # map the requests to the functions
    $self->request()->log->info($self->request()->method() ." connect/$path");
    if     ( $self->request()->method() =~ /^GET$/i )
    {
        if    ( $path =~ /^systems\/activations\/?$/ ) { return $self->get_activations(); }
        elsif ( $path =~ /^systems\/products\/?$/ )    { return $self->get_extensions(); }
    }
    elsif ( $self->request()->method() =~ /^POST$/i )
    {
        if    ( $path =~ /^systems\/products\/?$/ )    { return $self->products(); }
    }
    elsif ( $self->request()->method() =~ /^PUT$/i || $self->request()->method() =~ /^PATCH$/i)
    {
        if    ( $path =~ /^systems\/?$/ )              { return $self->update_system(); }
        elsif ( $path =~ /^systems\/products\/?$/ )    { return $self->update_product(); }
    }
    elsif ( $self->request()->method() =~ /^DELETE$/i )
    {
        if    ( $path =~ /^systems\/?$/ )              { return $self->delete_system(); }
    }

    return (undef, undef);
}

=item subscriptions_handler

=cut

sub subscriptions_handler($$$$)
{
    my $self = shift;
    my $path = $self->sub_path();

    # map the requests to the functions
    $self->request()->log->info($self->request()->method() ." connect/$path");
    if    ( $self->request()->method() =~ /^GET$/i )
    {
    }
    elsif ( $self->request()->method() =~ /^POST$/i )
    {
        if ( $path =~ /^subscriptions\/systems\/?$/ ) { return $self->announce(); }
    }
    elsif ( $self->request()->method() =~ /^PUT$/i )
    {
    }
    elsif ( $self->request()->method() =~ /^DELETE$/i )
    {
    }

    return (undef, undef);
}

=item update_system

PUT /connect/systems

=cut

sub update_system
{
    my $self = shift || return (undef, undef);
    my $c    = JSON::decode_json($self->read_post());
    my $q_target = "";
    my $q_namespace = "";
    my $hostname = "";

    # We are sure, that user is a system GUID
    my $guid = $self->user();

    if ( exists $c->{hostname} && $c->{hostname})
    {
        $hostname = $c->{hostname};
    }
    else
    {
        $hostname = $self->request()->connection()->remote_host();
    }
    if (! $hostname)
    {
        $hostname = $self->request()->connection()->remote_ip();
    }

    if ( exists $c->{distro_target} && $c->{distro_target})
    {
        $q_target = ", target = ".$self->dbh()->quote($c->{distro_target});
    }

    my $clientId = SMT::Utils::lookupClientIdByGUID($self->dbh(), $guid, $self->request());

    my $statement = sprintf("UPDATE Clients SET
                             hostname = %s %s
                             WHERE id = %s",
                             $self->dbh()->quote($hostname),
                             $q_target,
                             $self->dbh()->quote($clientId));
    $self->request()->log->info("STATEMENT: $statement");
    eval
    {
        $self->dbh()->do($statement);
    };
    if ($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }

    return $self->_storeMachineData($clientId, $c);
}

=item delete_system

DELETE /connect/systems

=cut

sub delete_system
{
    my $self = shift || return (undef, undef);

    # We are sure, that user is a system GUID
    my $guid = $self->user();

    # ON DELETE CASCADE take care of all the other tables
    $sql = sprintf("DELETE FROM Clients WHERE guid=%s",
                   $self->dbh()->quote($guid));
    $self->request()->log->info("STATEMENT: $sql");
    eval {
        $self->dbh()->do($sql);
    };
    if($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }

    return (Apache2::Const::HTTP_NO_CONTENT, "");
}


=item announce

POST /connect/subscriptions/systems

announce a system. This call create a system object in the DB
and return system username and password to the client.
all params are optional.

=cut

sub announce
{
    my $self = shift || return (undef, undef);
    my $c    = JSON::decode_json($self->read_post());

    my $result = {};
    my $hostname = "";
    my $target = "";
    my $namespace = "";

    if ( exists $c->{hostname} && $c->{hostname})
    {
        $hostname = $c->{hostname};
    }
    else
    {
        $hostname = $self->request()->connection()->remote_host();
    }
    if (! $hostname)
    {
        $hostname = $self->request()->connection()->remote_ip();
    }

    if ( exists $c->{distro_target} && $c->{distro_target})
    {
        $target = $c->{distro_target};
    }
    else
    {
        $self->request()->log_error("No distro_target provided");
        return (undef, undef);
    }

    if ( exists $c->{namespace} && $c->{namespace})
    {
        $namespace = $c->{namespace};
    }

    my $guid = `/usr/bin/uuidgen 2>/dev/null`;
    if (!$guid)
    {
        return undef;
    }
    chomp($guid);
    $guid =~ s/-//g;  # remove the -
    $result->{login} = "SCC_$guid"; # SUSEConnect always add this prefix
    my $secret = `/usr/bin/uuidgen 2>/dev/null`;
    if (!$secret)
    {
        return undef;
    }
    chomp($secret);
    $secret =~ s/-//g;  # remove the -
    $result->{password} = $secret;

    # we have all data; store it and send <zmdconfig>
    # for cloud quests verify they are authorized to access the server
    my $verifyModule = $self->cfg()->val('LOCAL', 'cloudGuestVerify');
    if ($verifyModule && $verifyModule ne 'none')
    {
        my $module = "SMT::Client::$verifyModule";
        (my $modFile = $module) =~ s|::|/|g;
        eval
        {
            require $modFile . '.pm';
        };
        if ($@)
        {
            $self->request()->log_error(
             "Failed to load guest verification module '$modFile.pm'\n$@");
           return (Apache2::Const::SERVER_ERROR,
              "Internal Server Error. Please contact your administrator.");
        }
        my $result = $module->verifySCCGuest($self->request(), $c, $result);
        if (! $result)
        {
            $self->request()->log_error("Guest verification failed\n");
            return (Apache2::Const::FORBIDDEN,
                 "Guest verification failed repository access denied");
        }
    }

    my $statement = sprintf("INSERT INTO Clients (guid, hostname, target, secret, regtype)
                             VALUES (%s, %s, %s, %s, 'SC')",
                             $self->dbh()->quote($result->{login}),
                             $self->dbh()->quote($hostname),
                             $self->dbh()->quote($target),
                             $self->dbh()->quote($result->{password}));
    $self->request()->log->info("STATEMENT: $statement");
    eval
    {
        $self->dbh()->do($statement);
    };
    if ($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }
    my $clientId = SMT::Utils::lookupClientIdByGUID($self->dbh(), $result->{login}, $self->request());
    $self->_storeMachineData($clientId, $c);

    return (Apache2::Const::OK, $result);
}

=item products

POST /connect/systems/products

register one product for this system

=cut

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
    else
    {
        # sometimes people provide edition instead of version, so let's stip the release
        my ($v, $r) = split(/-/, $c->{version}, 2);
        $c->{version} = $v;
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
    my $clientId = SMT::Utils::lookupClientIdByGUID($self->dbh(), $guid, $self->request());
    if(not $clientId)
    {
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "No valid client found");
    }

    #
    # insert registration
    #
    my $existingregs = SMT::Utils::lookupRegistrationByGUID($self->dbh(), $guid, $self->request());
    if(exists $existingregs->{$productId} && $existingregs->{$productId})
    {
        $statement = sprintf("UPDATE Registration SET regdate=%s
                               WHERE client_id=%s AND product_id=%s",
                             $self->dbh()->quote( SMT::Utils::getDBTimestamp()),
                             $self->dbh()->quote($clientId),
                             $self->dbh()->quote($productId));
    }
    else
    {
        $statement = sprintf("INSERT INTO Registration (client_id, product_id, regdate)
                              VALUES (%s, %s, %s)",
                             $self->dbh()->quote($clientId),
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
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }

    $self->_storeProductData($clientId, $productId, $c);

    #
    # lookup the Clients target
    #
    my $target = SMT::Utils::lookupTargetForClient($self->dbh(), $guid, $self->request());

    #
    # find Repositories
    #
    $existingregs = SMT::Utils::lookupRegistrationByGUID($self->dbh(), $guid, $self->request());
    my @pidarr = keys %{$existingregs};
    my $catalogs = SMT::Registration::findRepositories($self->request(), $self->dbh(), $target, \@pidarr);

    if ( (keys %{$catalogs}) == 0)
    {
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "No repositories found");
    }
    # return result
    return $self->_registrationResult($productId);
}

=item update_product

PUT /connect/systems/products

=cut

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
    my $former_identifier = $args->{identifier};

    # We are sure, that user is a system GUID
    my $guid = $self->user();
    my $clientId = SMT::Utils::lookupClientIdByGUID($self->dbh(), $guid, $self->request());

    # sometimes people provide edition instead of version, so let's stip the release
    my ($v, $r) = split(/-/, $args->{version}, 2);
    $args->{version} = $v;

    my $release = ((exists $args->{release_type})?$args->{release_type}:"");
    my $req_pdid = SMT::Utils::lookupProductIdByName($self->dbh(), $args->{identifier},
                                                     $args->{version}, $release,
                                                     $args->{arch}, $self->request());
    my $sql = sprintf("SELECT former_identifier
                         FROM Products
                        WHERE id = %s",
                      $self->dbh()->quote($req_pdid));
    $self->request()->log->info("STATEMENT: $sql");
    eval {
        my $fident = $self->dbh()->selectcol_arrayref($sql)->[0];
        if ($fident && $fident ne $former_identifier)
        {
            $former_identifier = $fident;
        }
    };
    if($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr)
    }

    # FIXME: start workaround
    my $reg_products = [];
    my $sql = sprintf("SELECT p.id
                         FROM Products p
                         JOIN Registration r ON r.product_id = p.id
                        WHERE r.client_id = %s
                          AND (p.product = %s OR p.product = %s)
                      ",
                      $self->dbh()->quote($clientId),
                      $self->dbh()->quote($args->{identifier}),
                      $self->dbh()->quote($former_identifier)
    );
    $self->request()->log->info("STATEMENT: $sql");
    eval {
        $old_pdid = $self->dbh()->selectcol_arrayref($sql)->[0];
    };
    if($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr)
    }

    # FIXME: this is how it should be when SCC provide complete data
    #        but we need a workaround until then

    # comparing if the destination product has the same PRODUCT_CLASS
    # as one of the registered products. To prevent updating incompatible
    # products
#
#     my $sql = sprintf("SELECT p.id, p.PRODUCT_CLASS
#                          FROM Products p
#                          JOIN Registration r ON r.PRODUCTID = p.ID
#                         WHERE r.GUID = %s
#                           AND p.PRODUCT_CLASS is not NULL
#                       ", $self->dbh()->quote($guid));
#     $self->request()->log->info("STATEMENT: $sql");
#     eval {
#         $product_classes = $self->dbh()->selectall_hashref($sql, "PRODUCT_CLASS");
#     };
#     if($@)
#     {
#         return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr)
#     }
#
#     $sql = sprintf("SELECT PRODUCT_CLASS FROM Products WHERE ID = %s", $self->dbh()->quote($req_pdid));
#     $self->request()->log->info("STATEMENT: $sql");
#     eval {
#         my $new_class = $self->dbh()->selectcol_arrayref($sql)->[0];
#         if((!$new_class) || (!exists $product_classes->{$new_class}))
#         {
#             return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY,
#                     "Destination Product requires a different subscription");
#         }
#         else
#         {
#             $old_pdid = $product_classes->{$new_class}->{ID};
#         }
#     };
#     if($@)
#     {
#         return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
#     }
    if($old_pdid && $req_pdid)
    {
        $sql = sprintf("UPDATE Registration
                           SET product_id = %s
                         WHERE client_id  = %s
                           AND product_id = %s",
                       $self->dbh()->quote($req_pdid),
                       $self->dbh()->quote($clientId),
                       $self->dbh()->quote($old_pdid));
        $self->request()->log->info("STATEMENT: $sql");
        eval {
            $self->dbh()->do($sql);
        };
        if($@)
        {
            return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
        }
        $self->_storeProductData($clientId, $productId, $args, $old_pdid);
    }
    else
    {
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY,
                "No installed product with requested update product found");
    }
    return $self->_registrationResult($req_pdid);
}

=item get_activations

GET /connect/systems/activations

=cut

sub get_activations
{
    my $self = shift || return (undef, undef);
    my $activations = [];

    # We are sure, that user is a system GUID
    my $guid = $self->user();

    my $sql = "SELECT c.id system_id,
                      s.regcode regcode,
                      s.subtype type,
                      s.substatus status,
                      DATE_FORMAT(s.substartdate, '%Y-%m-%dT%TZ') starts_at,
                      DATE_FORMAT(s.subenddate, '%Y-%m-%dT%TZ') expires_at,
                      r.product_id
                 FROM Registration r
                 JOIN Clients c ON r.client_id = c.id
            LEFT JOIN ClientSubscriptions cs ON c.id = cs.client_id
            LEFT JOIN Subscriptions s ON cs.subscription_id = s.id
                WHERE c.guid = ".$self->dbh()->quote($guid);

    $self->request()->log->info("STATEMENT: $sql");
    eval
    {
        my $baseURL = $self->cfg()->val('LOCAL', 'url');
        $baseURL =~ s/\/*$//;

        my $res = $self->dbh()->selectall_hashref($sql, 'product_id');
        if (scalar(keys %{$res}) == 0)
        {
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
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }
    # log->info is limited in strlen. If you want to see all, you need to print to STDERR
    #print STDERR "ACTIVATIONS: ".Data::Dumper->Dump([$activations])."\n";

    return (Apache2::Const::OK, $activations);
}

=item get_extensions

GET /connect/systems/products

=cut

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
                p.friendly friendly_name,
                p.friendly name,
                p.product identifier,
                p.former_identifier,
                p.description,
                p.version,
                p.rel release_type,
                p.arch,
                p.product_class,
                p.cpe,
                p.eula_url,
                1 free,
                p.product_type,
                (CASE WHEN (SELECT rp.domirror
                              FROM ProductRepositories pr
                              JOIN Repositories rp ON pr.repository_id = rp.id
                             WHERE pr.product_id = p.id
                               AND rp.domirror = 'N'
                               AND pr.optional = 'N'
                          GROUP BY rp.domirror) = 'N'
                 THEN 0 ELSE 1 END ) available
           FROM Registration r
           JOIN Products p ON r.product_id = p.id
           JOIN Client c ON r.client_id = c.id
          WHERE c.guid = %s
            AND r.product_id = %s
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
            return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "The requested product is not activated on this system.");
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

    # log->info is limited in strlen. If you want to see all, you need to print to STDERR
    #print STDERR "PRODUCTS: ".Data::Dumper->Dump([$result->{$req_pdid}])."\n";

    return (($result?Apache2::Const::OK:Apache2::Const::HTTP_UNPROCESSABLE_ENTITY), $result->{$req_pdid});
}

################ PRIVATE ####################

sub _storeProductData
{
    my $self      = shift || return;
    my $clientId  = shift || return;
    my $productId = shift || return;
    my $c         = shift || return;
    my $old_pdid  = shift;

    #
    # insert product info into MachineData
    #
    $sth = $self->dbh()->prepare("DELETE FROM MachineData
                                   WHERE client_id=:cid
                                     AND md_key LIKE :key");
    eval {
        $sth->do_h(cid=>$clientId, key=>"product-%-$productId");
        if($old_pdid)
        {
            $sth->do_h(cid=>$clientId, key=>"product-%-$old_pdid");
        }
    };
    if($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }
    $sth = $self->dbh()->prepare("INSERT INTO MachineData
                                         (client_id, md_key, md_value)
                                  VALUES (:cid, :key, :val)");
    eval {
        $cnt = $self->dbh()->do_h(cid=>$clientId,
                                  key=>"product-name-$productId",
                                  val=>$c->{identifier});
        $cnt = $self->dbh()->do_h(cid=>$clientId,
                                  key=>"product-version-$productId",
                                  val=>$c->{version});
        $cnt = $self->dbh()->do_h(cid=>$clientId,
                                  key=>"product-arch-$productId",
                                  val=>$c->{arch});
        $cnt = $self->dbh()->do_h(cid=>$clientId,
                                  key=>"product-rel-$productId",
                                  val=>$c->{release_type});
        $cnt = $self->dbh()->do_h(cid=>$clientId,
                                  key=>"product-token-$productId",
                                  val=>((exists $c->{token} && $c->{token})?$c->{token}:''));
    };
    if($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }
}

sub _storeMachineData
{
    my $self     = shift || return;
    my $clientId = shift || return;
    my $c        = shift || return;

    my $stht = $self->dbh()->prepare("SELECT 1
                                        FROM SystemData
                                       WHERE client_id = :cid");
    $stht->execute_h(cid=>$clientId);
    my $sth;
    if( $stht->fetchrow_arry() )
    {
        $sth = $self->dbh()->prepare("UPDATE SystemData SET
                                             data = :json
                                       WHERE client_id = :cid");
    }
    else
    {
        $sth = $self->dbh()->prepare("INSERT INTO SystemData (client_id, data)
                                      VALUES (:cid, :json)");
    }
    eval {
        $sth->do_h(cid=>$clientId, json => encode_json($c))
    };
    if($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }
    return (Apache2::Const::OK, {});
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
               e.friendly friendly_name,
               e.friendly name,
               e.product identifier,
               e.former_identifier,
               e.description,
               e.version,
               e.rel release_type,
               e.arch,
               e.product_class,
               e.cpe,
               e.eula_url,
               1 free,
               e.product_type,
               (CASE WHEN (SELECT rp.domirror
                             FROM ProductRepositories pr
                             JOIN Repositories rp ON pr.repository_id = rp.id
                            WHERE pr.product_id = e.id
                              AND rp.domirror = 'N'
                              AND pr.optional = 'N'
                         GROUP BY rp.domirror) = 'N'
                THEN 0 ELSE 1 END ) available
          FROM Products p
          JOIN ProductExtensions pe ON p.id = pe.product_id
          JOIN Products e ON pe.extension_id = e.id
          WHERE p.id in (%s)
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
            $result->{$pdid}->{repositories} = $self->_repositories_for_product($baseURL, $result->{$pdid}->{id});
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

sub _getProduct
{
    my $self = shift || return {};
    my $product_id  = shift || return {};

    my $sql = sprintf("
        SELECT p.id id,
               p.friendly friendly_name,
               p.friendly name,
               p.product identifier,
               p.former_identifier,
               p.description,
               p.version,
               p.rel release_type,
               p.arch,
               p.product_class,
               p.cpe,
               p.eula_url,
               1 free,
               p.product_type,
               (CASE WHEN (SELECT rp.domirror
                             FROM ProductRepositories pr
                             JOIN Repositories rp ON pr.repository_id = rp.id
                            WHERE pr.product_id = p.id
                              AND rp.domirror = 'N'
                              AND pr.optional = 'N'
                         GROUP BY rp.domirror) = 'N'
                THEN 0 ELSE 1 END ) available
          FROM Products p
         WHERE p.id = %s
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
    my $enabled_repositories = [];
    my $repositories = [];

    my $sql = sprintf("
        SELECT r.id,
               r.name,
               r.target distro_target,
               r.description,
               CONCAT(%s, '/repo/', r.localpath) url,
               r.autorefresh,
               pr.OPTIONAL
          FROM ProductRepositories pr
          JOIN Repositories r ON pr.repository_id = r.id
         WHERE pr.product_id = %s",
         $self->dbh()->quote($baseURL),
         $self->dbh()->quote($productid));
    $self->request()->log->info("STATEMENT: $sql");
    eval
    {
        foreach my $repo (@{$self->dbh()->selectall_arrayref($sql, {Slice => {}})})
        {
            $repo->{autorefresh} = (($repo->{autorefresh} eq 'Y')?JSON::true:JSON::false);
            $repo->{enabled} = (($repo->{OPTIONAL} eq 'N')?JSON::true:JSON::false);
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

=back

=head1 AUTHOR

mc@suse.de

=head1 COPYRIGHT

Copyright 2014 SUSE LINUX Products GmbH, Nuernberg, Germany.

=cut

1;
