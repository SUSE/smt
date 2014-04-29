package SMT::RestSCCSystems;

use strict;
use warnings;

use APR::Brigade ();
use APR::Bucket ();
use APR::Const     -compile => qw(:error SUCCESS BLOCK_READ);
use constant IOBUFSIZE => 8192;
use Apache2::Filter ();

use APR::Brigade;

use Apache2::RequestRec ();
use Apache2::RequestIO ();
use Apache2::Access ();

use Apache2::Const -compile => qw(OK SERVER_ERROR HTTP_UNAUTHORIZED NOT_FOUND FORBIDDEN AUTH_REQUIRED MODE_READBYTES HTTP_UNPROCESSABLE_ENTITY :log HTTP_NO_CONTENT);
use Apache2::RequestUtil;

use JSON;

use SMT::Utils;
use SMT::Client;
use SMT::Registration;
use DBI qw(:sql_types);
use Data::Dumper;

sub _registrationResult
{
    my $r   = shift || return undef;
    my $dbh = shift || return undef;
    my $catalogs = shift || return undef;
    my $namespace  = shift || '';

    my $cfg = undef;

    eval
    {
        $cfg = SMT::Utils::getSMTConfig();
    };
    if($@ || !defined $cfg)
    {
        $r->log_error("Cannot read the SMT configuration file: ".$@);
        return ( Apache2::Const::SERVER_ERROR, "SMT server is missconfigured. Please contact your administrator.");
    }

    my $LocalNUUrl = $cfg->val('LOCAL', 'url');
    my $LocalBasePath = $cfg->val('LOCAL', 'MirrorTo');
    my $aliasChange = $cfg->val('NU', 'changeAlias');
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
        $r->log_error("Invalid url parameter in smt.conf. Please fix the url parameter in the [LOCAL] section.");
        return (Apache2::Const::SERVER_ERROR, "SMT server is missconfigured. Please contact your administrator.");
    }
    my $localID = "SMT-".$LocalNUUrl;
    $localID =~ s/:*\/+/_/g;
    $localID =~ s/\./_/g;
    $localID =~ s/_$//;

    my ($status, $password) = $r->get_basic_auth_pw;
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
        'login' => $r->user,
        'password' => $password,
        'norefresh' => \@norefresh,
        'enabled' => \@enabled,
        'subscription' => undef,
        'location' => undef
    };
    return (Apache2::Const::OK, $response);
}

sub _repositories_for_product
{
    my $r   = shift || return ([], []);
    my $dbh = shift || return ([], []);
    my $productid = shift || return ([], []);
    my $enabled_repositories = [];
    my $repositories = [];

    my $sql = sprintf("
        select c.id,
               c.name,
               c.target distro_target,
               c.description,
               c.exturl url,
               c.autorefresh,
               pc.OPTIONAL
          from ProductCatalogs pc
          join Catalogs c ON pc.catalogid = c.id
         where pc.productid = %s",
         $dbh->quote($productid));
    $r->log->info("STATEMENT: $sql");
    eval
    {
        foreach my $repo (@{$dbh->selectall_arrayref($sql, {Slice => {}})})
        {
            $r->log->info("REPO: $repo");
            push @{$enabled_repositories}, $repo->{id} if ($repo->{OPTIONAL} eq 'N');
            delete $repo->{OPTIONAL};
            push @{$repositories}, $repo;
        }
    };
    if ($@)
    {
        $r->log_error("DBERROR: $@ ".$dbh->errstr);
    }
    return ($enabled_repositories, $repositories);
}


sub _extensions_for_products
{
    my $r   = shift || return {};
    my $dbh = shift || return {};
    my $productids = shift || return {};
    my $result = {};

    if (scalar(@{$productids}) == 0)
    {
        $r->log->info("no more extensions");
        return {};
    }
    foreach (@{$productids})
    {
        $_ = $dbh->quote($_);
    }
    my $sql = sprintf("
        SELECT e.id id,
               e.FRIENDLY friendly_name,
               e.PRODUCT zypper_name,
               e.DESCRIPTION description,
               e.VERSION zypper_version,
               e.REL release_type,
               e.ARCH arch,
               e.PRODUCT_CLASS product_class,
               e.CPE cpe,
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
    $r->log->info("STATEMENT: $sql");
    eval
    {
        my $new_ids = [];
        my $res = $dbh->selectall_hashref($sql, 'id');
        foreach my $product (values %{$res})
        {
            $product->{extensions} = [];
            foreach my $ext ( values %{_extensions_for_products($r, $dbh, [int($product->{id})])})
            {
                push @{$product->{extensions}}, $ext;
            }
            $product->{free} = ($product->{free} eq "0"?JSON::false:JSON::true);
            $product->{available} = ($product->{available} eq "0"?JSON::false:JSON::true);
            $product->{id} = int($product->{id});
            ($product->{enabled_repositories}, $product->{repositories}) =
                _repositories_for_product($r, $dbh, $product->{id});
            $result->{$product->{id}} = $product;
        }
    };
    if ($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    return $result;
}

sub get_extensions($$)
{
    my $r   = shift || return undef;
    my $dbh = shift || return undef;
    my $result = {};
    my $sql = "";
    # We are sure, that user is a system GUID
    my $guid = $r->user;

    my $args = parse_args($r);
    $sql = sprintf(
        "SELECT p.ID id
           FROM Registration r
           JOIN Products p ON r.PRODUCTID = p.ID
          WHERE r.GUID = %s
        ", $dbh->quote($guid));

    if(exists $args->{product_ident} && $args->{product_ident})
    {
        $sql .= sprintf(" AND p.PRODUCT = %s", $dbh->quote($args->{product_ident}));
    }
    $r->log->info("STATEMENT: $sql");
    eval
    {
        $result = _extensions_for_products($r, $dbh, $dbh->selectcol_arrayref($sql));
    };
    if ($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }

    return (($result?Apache2::Const::OK:Apache2::Const::HTTP_UNPROCESSABLE_ENTITY), [values %{$result}]);
}

sub update_system($$$)
{
    my $r = shift || return undef;
    my $dbh = shift || return undef;
    my $c = shift || return undef;
    my $q_target = "";
    my $q_namespace = "";
    my $hostname = "";

    # We are sure, that user is a system GUID
    my $guid = $r->user;

    if ( exists $c->{hostname} && $c->{hostname})
    {
        $hostname = $c->{hostname};
    }
    else
    {
        $hostname = $r->connection()->remote_host();
    }
    if (! $hostname)
    {
        $hostname = $r->connection()->remote_ip();
    }

    if ( exists $c->{distro_target} && $c->{distro_target})
    {
        $q_target = ", TARGET = ".$dbh->quote($c->{distro_target});
    }

    if ( exists $c->{namespace} && $c->{namespace})
    {
        $q_namespace = ", NAMESPACE = ".$dbh->quote($c->{namespace});
    }

    my $statement = sprintf("UPDATE Clients SET
                             HOSTNAME = %s %s %s
                             WHERE GUID = %s",
                             $dbh->quote($hostname),
                             $q_target,
                             $q_namespace,
                             $dbh->quote($guid));
    $r->log->info("STATEMENT: $statement");
    eval
    {
        $dbh->do($statement);
    };
    if ($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }

    #
    # insert product info into MachineData
    #
    $statement = sprintf("DELETE from MachineData where GUID=%s AND KEYNAME = 'machinedata'",
                        $dbh->quote($guid));
    $r->log->info("STATEMENT: $statement");
    eval {
        $dbh->do($statement);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, 'machinedata', %s)",
                        $dbh->quote($guid),
                        $dbh->quote(encode_json($c)));
    $r->log->info("STATEMENT: $statement");
    eval {
        $dbh->do($statement);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    return (Apache2::Const::OK, {});
}


#
# announce a system. This call create a system object in the DB
# and return system username and password to the client.
# all params are optional.
#
# QUESTION: no chance to check duplicate clients?
#           Every client should call this only once?
#
sub products($$$)
{
    my $r   = shift || return undef;
    my $dbh = shift || return undef;
    my $c   = shift || return undef;
    my $result = {};
    my $cnt = 0;

    # We are sure, that user is a system GUID
    my $guid = $r->user;
    my $token = "";
    my $email = "";
    my $statement = "";

    if ( exists $c->{token} && $c->{token})
    {
        # Token in SMT is not a required parameter
        if(not SMT::Utils::lookupSubscriptionByRegcode($dbh, $c->{token}, $r))
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

    my $productId = SMT::Utils::lookupProductIdByName($dbh, $c->{product_ident}, $c->{product_version},
                                                      $c->{release_type}, $c->{arch});
    if(not $productId)
    {
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "No valid product found");
    }

    #
    # insert registration
    #
    my $existingregs = SMT::Utils::lookupRegistrationByGUID($dbh, $guid, $r);
    if(exists $existingregs->{$productId} && $existingregs->{$productId})
    {
        $statement = sprintf("UPDATE Registration SET REGDATE=%s WHERE GUID=%s AND PRODUCTID=%s",
                             $dbh->quote( SMT::Utils::getDBTimestamp()),
                             $dbh->quote($guid),
                             $dbh->quote($productId));
    }
    else
    {
        $statement = sprintf("INSERT INTO Registration (GUID, PRODUCTID, REGDATE) VALUES (%s, %s, %s)",
                             $dbh->quote($guid),
                             $dbh->quote($productId),
                             $dbh->quote( SMT::Utils::getDBTimestamp()));
    }
    $r->log->info("STATEMENT: $statement");
    eval
    {
        $dbh->do($statement);
    };
    if ($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    #
    # insert product info into MachineData
    #
    $statement = sprintf("DELETE from MachineData where GUID=%s AND KEYNAME LIKE %s",
                         $dbh->quote($guid),
                         $dbh->quote("product-%-$productId"));
    eval {
        $cnt = $dbh->do($statement);
        $r->log->info("STATEMENT: $statement  Affected rows: $cnt");
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                         $dbh->quote($guid),
                         $dbh->quote("product-name-$productId"),
                         $dbh->quote($c->{product_ident}));
    $r->log->info("STATEMENT: $statement");
    eval {
        $cnt = $dbh->do($statement);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                         $dbh->quote($guid),
                         $dbh->quote("product-version-$productId"),
                         $dbh->quote($c->{product_version}));
    $r->log->info("STATEMENT: $statement");
    eval {
        $cnt = $dbh->do($statement);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                         $dbh->quote($guid),
                         $dbh->quote("product-arch-$productId"),
                         $dbh->quote($c->{arch}));
    $r->log->info("STATEMENT: $statement");
    eval {
        $cnt = $dbh->do($statement);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                         $dbh->quote($guid),
                         $dbh->quote("product-rel-$productId"),
                         $dbh->quote($c->{release_type}));
    $r->log->info("STATEMENT: $statement");
    eval {
        $cnt = $dbh->do($statement);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    if ( exists $c->{token} && $c->{token})
    {
        # if we got a tokem, store it for later transfer to SCC.
        $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                            $dbh->quote($guid),
                            $dbh->quote("product-token-$productId"),
                            $dbh->quote($c->{token}));
        $r->log->info("STATEMENT: $statement");
        eval {
            $cnt = $dbh->do($statement);
        };
        if($@)
        {
            $r->log_error("DBERROR: ".$dbh->errstr);
        }
    }


    #
    # lookup the Clients target
    #
    my $target = SMT::Utils::lookupTargetForClient($dbh, $guid, $r);

    #
    # find Catalogs
    #
    $existingregs = SMT::Utils::lookupRegistrationByGUID($dbh, $guid, $r);
    my @pidarr = keys %{$existingregs};
    my $catalogs = SMT::Registration::findCatalogs($r, $dbh, $target, \@pidarr);

    if ( (keys %{$catalogs}) == 0)
    {
        $r->log->info("No repositories found");
        return (Apache2::Const::HTTP_UNPROCESSABLE_ENTITY, "No repositories found");
    }

    # TODO: get status - from SMT?

    # return result
    return _registrationResult($r, $dbh, $catalogs);
}

sub delete_system($$)
{
    my $r   = shift || return undef;
    my $dbh = shift || return undef;

    # We are sure, that user is a system GUID
    my $guid = $r->user;

    my $sql = sprintf("DELETE from MachineData where GUID=%s",
                      $dbh->quote($guid));
    $r->log->info("STATEMENT: $sql");
    eval {
        $dbh->do($sql);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    $sql = sprintf("DELETE from Registration where GUID=%s",
                   $dbh->quote($guid));
    $r->log->info("STATEMENT: $sql");
    eval {
        $dbh->do($sql);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    $sql = sprintf("DELETE from Clients where GUID=%s",
                   $dbh->quote($guid));
    $r->log->info("STATEMENT: $sql");
    eval {
        $dbh->do($sql);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    $sql = sprintf("DELETE from ClientSubscriptions where GUID=%s",
                   $dbh->quote($guid));
    $r->log->info("STATEMENT: $sql");
    eval {
        $dbh->do($sql);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }

    return (Apache2::Const::HTTP_NO_CONTENT, "");
}

#
# the handler for requests to the jobs ressource
#
sub systems_handler($$)
{
    my $r   = shift || return undef;
    my $dbh = shift || return undef;
    my $path = sub_path($r);

    # map the requests to the functions
    if    ( $r->method() =~ /^GET$/i )
    {
        if ( $path =~ /^systems\/products/ )
        {
            return get_extensions($r, $dbh);
        }
        else { return undef; }
    }
    elsif ( $r->method() =~ /^POST$/i )
    {
        if ( $path =~ /^systems\/products/ )
        {
            my $c = JSON::decode_json(read_post($r));
            return products($r, $dbh, $c);
        }
        else { return undef; }
    }
    elsif ( $r->method() =~ /^PUT$/i || $r->method() =~ /^PATCH$/i)
    {
        if ( $path =~ /^systems\/?$/ )
        {
            my $c = JSON::decode_json(read_post($r));
            return update_system($r, $dbh, $c);
        }
        else { return undef; }
    }
    elsif ( $r->method() =~ /^DELETE$/i )
    {
        if ( $path =~ /^systems\/?$/ )
        {
            return delete_system($r, $dbh);
        }
        else { return undef; }
    }
    else
    {
        $r->log->error("Unknown request to the systems interface.");
        return undef;
    }

    return undef;
}


#
# Apache Handler
# this is the main function of this request handler
#
sub handler {
    my $r = shift;
    my $path = sub_path($r);
    my $code = Apache2::Const::SERVER_ERROR;
    my $data = "";

    # try to connect to the database - else report server error
    my $dbh = undef;
    if ( ! ($dbh=SMT::Utils::db_connect()) )
    {
        $r->log->error("RESTService could not connect to database.");
        return Apache2::Const::SERVER_ERROR;
    }

    # REST Services need authentication
    return Apache2::Const::AUTH_REQUIRED unless ( defined $r->user  &&  $r->user ne '' );

    my ($status, $password) = $r->get_basic_auth_pw;
    return respond_with_error($r, $status, "unauthorized") unless $status == Apache2::Const::OK;

    # to be sure that the authentication happens with GUID/SECRET and not with
    # mirror credentails
    my $client = SMT::Client->new({ 'dbh' => $dbh });
    my $auth = $client->authenticateByGUIDAndSecret($r->user, $password);
    if ( keys %{$auth} != 1 )
    {
        $r->log->error("No client authentication provided");
        return respond_with_error($r, Apache2::Const::FORBIDDEN, "No client authentication provided") ;
    }

    my $update_last_contact = update_last_contact($r, $dbh);
    if ( $update_last_contact )
    {
        $r->log->info(sprintf("Request from client (%s). Updated its last contact timestamp.", $r->user) );
    }
    else
    {
        $r->log->info(sprintf("Request from client (%s). Could not updated its last contact timestamp.", $r->user) );
    }

    if    ( $path =~ qr{^systems?}    ) {  ($code, $data) = systems_handler($r, $dbh); }

    if (! defined $code || !($code == Apache2::Const::OK || $code == Apache2::Const::HTTP_NO_CONTENT))
    {
        return respond_with_error($r, $code, $data);
    }
    elsif ($code != Apache2::Const::HTTP_NO_CONTENT)
    {
        $r->content_type('application/json');
        $r->err_headers_out->add('Cache-Control' => "no-cache, public, must-revalidate");
        $r->err_headers_out->add('Pragma' => "no-cache");

        print encode_json($data);
    }

   return $code;
}

#
# get the proper sub-path info part
#  cropps the prefix of the path: "/connect/"
#
sub sub_path($)
{
    my $r = shift || return '';

    # get the path_info
    my $path = $r->path_info();
    # crop the prefix: '/'connect rest service identifier
    $path =~ s/^\/connect\/+//;
    # crop the trailing slash
    $path =~ s/\/?$//;
    # crop the beginning slash
    $path =~ s/^\/?//;

    return $path;
}

sub parse_args($)
{
    my $r = shift || return {};
    my $ret = {};
    foreach my $kv (split(/&/, $r->args()))
    {
        my ($k, $v) = split(/=/, $kv, 2);
        $ret->{$k} = $v;
    }
    return $ret;
}

#
# read the content of a POST and return the data
#
sub read_post {
    my $r = shift;

    my $bb = APR::Brigade->new($r->pool, $r->connection->bucket_alloc);

    my $data = '';
    my $seen_eos = 0;
    do {
        $r->input_filters->get_brigade($bb, Apache2::Const::MODE_READBYTES,
                                       APR::Const::BLOCK_READ, IOBUFSIZE);

        for (my $b = $bb->first; $b; $b = $bb->next($b)) {
            if ($b->is_eos) {
                $seen_eos++;
                last;
            }

            if ($b->read(my $buf)) { $data .= $buf; }
            $b->remove; # optimization to reuse memory
        }
    } while (!$seen_eos);

    $bb->destroy;
    $r->log->info("Got content: $data");
    return $data;
}


#
# update_last_contact
#
sub update_last_contact($$)
{
    my $r = shift || return undef;
    my $dbh = shift || return undef;

    my $client = SMT::Client->new({ 'dbh' => $dbh });
    return $client->updateLastContact($r->user);
}

sub respond_with_error
{
    my ($r, $code, $msg) = @_;
    if (! $code)
    {
        $code = Apache2::Const::NOT_FOUND;
        $msg  = "Not Found";
    }
    # errors are logged in each handler
    # returning undef from a handler is allowed, this will result in a 404 response, just as if no handler was defined for the request
    $r->status($code);
    $r->content_type('application/json');
    $r->custom_response($code, "");
    print encode_json({ 'error' => $msg,  'localized_error' => $msg, 'status' => $code });
    return $code;
}

1;

