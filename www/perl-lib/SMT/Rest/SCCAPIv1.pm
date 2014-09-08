package SMT::Rest::SCCAPIv1;

require SMT::Rest::Base;
@ISA = qw(SMT::Rest::Base);

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

sub systems_handler
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
        if     ( $path =~ /^systems\/products\/?$/ ) { return $self->get_extensions(); }
    }
    elsif ( $self->request()->method() =~ /^POST$/i )
    {
        if     ( $path =~ /^systems\/products\/?$/ ) { return $self->products(); }
    }
    elsif ( $self->request()->method() =~ /^PUT$/i || $self->request()->method() =~ /^PATCH$/i)
    {
        if     ( $path =~ /^systems\/?$/ )           { return $self->update_system(); }
    }
    elsif ( $self->request()->method() =~ /^DELETE$/i )
    {
        if     ( $path =~ /^systems\/?$/ )           { return $self->delete_system(); }
    }

    return (undef, undef);
}

#
# the handler for requests to the jobs ressource
#
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

sub get_extensions
{
    my $self = shift || return (undef, undef);
    my $result = {};
    my $sql = "";
    # We are sure, that user is a system GUID
    my $guid = $self->user();

    my $args = $self->parse_args();
    $sql = sprintf(
        "SELECT p.ID id
           FROM Registration r
           JOIN Products p ON r.PRODUCTID = p.ID
          WHERE r.GUID = %s
        ", $self->dbh()->quote($guid));

    if(exists $args->{product_ident} && $args->{product_ident})
    {
        $sql .= sprintf(" AND p.PRODUCT = %s", $self->dbh()->quote($args->{product_ident}));
    }
    $self->request()->log->info("STATEMENT: $sql");
    eval
    {
        $result = $self->_extensions_for_products($self->dbh()->selectcol_arrayref($sql));
    };
    if ($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }
    # log->info is limited in strlen. If you want to see all, you need to print to STDERR
    #print STDERR "PRODUCTS: ".Data::Dumper->Dump([$result])."\n";

    return (($result?Apache2::Const::OK:Apache2::Const::HTTP_UNPROCESSABLE_ENTITY), [values %{$result}]);
}

#
# announce a system (V1). This call create a system object in the DB
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

    if ( ! (exists $c->{product_ident} && $c->{product_ident}))
    {
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "Missing required parameter: product_ident");
    }

    if ( ! (exists $c->{product_version} && $c->{product_version}))
    {
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "Missing required parameter: product_version");
    }
    else
    {
        # sometimes people provide edition instead of version, so let's stip the release
        my ($v, $r) = split(/-/, $c->{product_version}, 2);
        $c->{product_version} = $v;
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

    my $productId = SMT::Utils::lookupProductIdByName($self->dbh(), $c->{product_ident}, $c->{product_version},
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
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
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
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }
    $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                         $self->dbh()->quote($guid),
                         $self->dbh()->quote("product-name-$productId"),
                         $self->dbh()->quote($c->{product_ident}));
    $self->request()->log->info("STATEMENT: $statement");
    eval {
        $cnt = $self->dbh()->do($statement);
    };
    if($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }
    $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                         $self->dbh()->quote($guid),
                         $self->dbh()->quote("product-version-$productId"),
                         $self->dbh()->quote($c->{product_version}));
    $self->request()->log->info("STATEMENT: $statement");
    eval {
        $cnt = $self->dbh()->do($statement);
    };
    if($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
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
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
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
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
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
            return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
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
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "No repositories found");
    }

    # TODO: get status - from SMT?

    # return result
    return $self->_registrationResult($catalogs);
}

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
        $q_target = ", TARGET = ".$self->dbh()->quote($c->{distro_target});
    }

    if ( exists $c->{namespace} && $c->{namespace})
    {
        $q_namespace = ", NAMESPACE = ".$self->dbh()->quote($c->{namespace});
    }

    my $statement = sprintf("UPDATE Clients SET
                             HOSTNAME = %s %s %s
                             WHERE GUID = %s",
                             $self->dbh()->quote($hostname),
                             $q_target,
                             $q_namespace,
                             $self->dbh()->quote($guid));
    $self->request()->log->info("STATEMENT: $statement");
    eval
    {
        $self->dbh()->do($statement);
    };
    if ($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }

    #
    # insert product info into MachineData
    #
    $statement = sprintf("DELETE from MachineData where GUID=%s AND KEYNAME = 'machinedata'",
                        $self->dbh()->quote($guid));
    $self->request()->log->info("STATEMENT: $statement");
    eval {
        $self->dbh()->do($statement);
    };
    if($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }
    $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, 'machinedata', %s)",
                        $self->dbh()->quote($guid),
                        $self->dbh()->quote(encode_json($c)));
    $self->request()->log->info("STATEMENT: $statement");
    eval {
        $self->dbh()->do($statement);
    };
    if($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }
    return (Apache2::Const::OK, {});
}

sub delete_system
{
    my $self = shift || return (undef, undef);

    # We are sure, that user is a system GUID
    my $guid = $self->user();

    my $sql = sprintf("DELETE from MachineData where GUID=%s",
                      $self->dbh()->quote($guid));
    $self->request()->log->info("STATEMENT: $sql");
    eval {
        $self->dbh()->do($sql);
    };
    if($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }
    $sql = sprintf("DELETE from Registration where GUID=%s",
                   $self->dbh()->quote($guid));
    $self->request()->log->info("STATEMENT: $sql");
    eval {
        $self->dbh()->do($sql);
    };
    if($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }
    $sql = sprintf("DELETE from Clients where GUID=%s",
                   $self->dbh()->quote($guid));
    $self->request()->log->info("STATEMENT: $sql");
    eval {
        $self->dbh()->do($sql);
    };
    if($@)
    {
        return (Apache2::Const::SERVER_ERROR, "DBERROR: ".$self->dbh()->errstr);
    }
    $sql = sprintf("DELETE from ClientSubscriptions where GUID=%s",
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


#
# announce a system. This call create a system object in the DB
# and return system username and password to the client.
# all params are optional.
#
# QUESTION: no chance to check duplicate clients?
#           Every client should call this only once?
#
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

    my $statement = sprintf("INSERT INTO Clients (GUID, HOSTNAME, TARGET, NAMESPACE, SECRET, REGTYPE)
                             VALUES (%s, %s, %s, %s, %s, 'SC')",
                             $self->dbh()->quote($result->{login}),
                             $self->dbh()->quote($hostname),
                             $self->dbh()->quote($target),
                             $self->dbh()->quote($namespace),
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

    $self->_storeMachineData($result->{login}, $c);

    return (Apache2::Const::OK, $result);
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
               e.PRODUCT zypper_name,
               e.DESCRIPTION description,
               e.VERSION zypper_version,
               e.REL release_type,
               e.ARCH arch,
               e.PRODUCT_CLASS product_class,
               e.CPE cpe,
               e.EULA_URL eula_url,
               1 free,
               ( SELECT (CASE c.MIRRORABLE WHEN 'N' THEN 0 ELSE 1 END)
                   FROM ProductCatalogs pc
                   JOIN Catalogs c ON pc.CATALOGID = c.ID
                  WHERE pc.PRODUCTID = e.ID
                    AND c.MIRRORABLE ='N'
               GROUP BY c.MIRRORABLE
               ) available
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
        my $res = $self->dbh()->selectall_hashref($sql, 'id');
        foreach my $product (values %{$res})
        {
            $product->{extensions} = [];
            foreach my $ext ( values %{$self->_extensions_for_products([int($product->{id})])})
            {
                push @{$product->{extensions}}, $ext;
            }
            $product->{free} = ($product->{free} eq "0"?JSON::false:JSON::true);
            $product->{available} = ($product->{available} eq "0"?JSON::false:JSON::true);
            $product->{id} = int($product->{id});
            ($product->{enabled_repositories}, $product->{repositories}) =
                $self->_repositories_for_product($baseURL, $product->{id});
            $result->{$product->{id}} = $product;
        }
    };
    if ($@)
    {
        if($self->dbh()->errstr)
        {
            $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
        }
        else
        {
            $self->request()->log_error("ERROR: $@");
        }
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
        select c.id,
               c.name,
               c.target distro_target,
               c.description,
               CONCAT(%s, '/repo/', c.localpath) url,
               c.autorefresh,
               pc.OPTIONAL
          from ProductCatalogs pc
          join Catalogs c ON pc.catalogid = c.id
         where pc.productid = %s",
         $self->dbh()->quote($baseURL),
         $self->dbh()->quote($productid));
    $self->request()->log->info("STATEMENT: $sql");
    eval
    {
        foreach my $repo (@{$self->dbh()->selectall_arrayref($sql, {Slice => {}})})
        {
            $repo->{autorefresh} = (($repo->{autorefresh} eq 'Y')?JSON::true:JSON::false);
            push @{$enabled_repositories}, $repo->{id} if ($repo->{OPTIONAL} eq 'N');
            delete $repo->{OPTIONAL};
            push @{$repositories}, $repo;
        }
    };
    if ($@)
    {
        $self->request()->log_error("DBERROR: $@ ".$self->dbh()->errstr);
    }
    return ($enabled_repositories, $repositories);
}

sub _registrationResult
{
    my $self     = shift || return (undef, undef);
    my $catalogs = shift || return (undef, undef);
    my $namespace  = shift || '';

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

    my ($status, $password) = $self->request()->get_basic_auth_pw;
    my @enabled = ();
    my @norefresh = ();

    foreach my $catid (keys %{$catalogs})
    {
        my $catname = $catalogs->{$catid}->{NAME};
        if ($namespace && uc($catalogs->{$catid}->{STAGING}) eq "Y" &&
            $aliasChange)
        {
            $catname .= ":$namespace";
        }
        push @enabled, $catname if (uc($catalogs->{$catid}->{OPTIONAL}) eq "N");
        push @norefresh, $catname if (uc($catalogs->{$catid}->{AUTOREFRESH}) eq "N");
    }
    my $response = {
        'sources' => {
            $localID => "$LocalNUUrl?credentials=$localID"
        },
        'login' => $self->user(),
        'password' => $password,
        'norefresh' => \@norefresh,
        'enabled' => \@enabled,
        'subscription' => undef,
        'location' => undef
    };
    return (Apache2::Const::OK, $response);
}

sub _storeMachineData
{
    my $self = shift || return;
    my $guid = shift || return;
    my $c    = shift || return;

    #
    # insert product info into MachineData
    #
    my $statement = sprintf("DELETE from MachineData where GUID=%s AND KEYNAME = %s",
                           $self->dbh()->quote($guid),
                           $self->dbh()->quote("machinedata"));
    $self->request()->log->info("STATEMENT: $statement");
    eval {
        $self->dbh()->do($statement);
    };
    if($@)
    {
        $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
    }
    $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                        $self->dbh()->quote($guid),
                        $self->dbh()->quote("machinedata"),
                        $self->dbh()->quote(encode_json($c)));
    $self->request()->log->info("STATEMENT: $statement");
    eval {
        $self->dbh()->do($statement);
    };
    if($@)
    {
        $self->request()->log_error("DBERROR: ".$self->dbh()->errstr);
    }
}

1;
