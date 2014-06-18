package SMT::RestSCCSubscriptions;

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

use Apache2::Const -compile => qw(OK SERVER_ERROR HTTP_UNAUTHORIZED NOT_FOUND FORBIDDEN AUTH_REQUIRED MODE_READBYTES HTTP_NOT_ACCEPTABLE :log HTTP_NO_CONTENT);
use Apache2::RequestUtil;

use JSON;

use SMT::Utils;
use DBI qw(:sql_types);
use Data::Dumper;

sub _storeMachineData($$$$)
{
    my $r = shift || return;
    my $dbh = shift || return;
    my $guid = shift || return;
    my $c = shift || return;

    #
    # insert product info into MachineData
    #
    my $statement = sprintf("DELETE from MachineData where GUID=%s AND KEYNAME = %s",
                           $dbh->quote($guid),
                           $dbh->quote("machinedata"));
    $r->log->info("STATEMENT: $statement");
    eval {
        $dbh->do($statement);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
    $statement = sprintf("INSERT INTO MachineData (GUID, KEYNAME, VALUE) VALUES (%s, %s, %s)",
                        $dbh->quote($guid),
                        $dbh->quote("machinedata"),
                        $dbh->quote(encode_json($c)));
    $r->log->info("STATEMENT: $statement");
    eval {
        $dbh->do($statement);
    };
    if($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }
}

#
# announce a system. This call create a system object in the DB
# and return system username and password to the client.
# all params are optional.
#
# QUESTION: no chance to check duplicate clients?
#           Every client should call this only once?
#
sub announce($$$$)
{
    my $r   = shift || return undef;
    my $dbh = shift || return undef;
    my $cfg = shift || return undef;
    my $c   = shift || return undef;
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
        $hostname = $r->connection()->remote_host();
    }
    if (! $hostname)
    {
        $hostname = $r->connection()->remote_ip();
    }

    if ( exists $c->{distro_target} && $c->{distro_target})
    {
        $target = $c->{distro_target};
    }
    else{
        # in future we may fail here
        ;
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
    my $verifyModule = $cfg->val('LOCAL', 'cloudGuestVerify');
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
            $r->log_error(
             "Failed to load guest verification module '$modFile.pm'\n$@");
           return (Apache2::Const::SERVER_ERROR,
              "Internal Server Error. Please contact your administrator.");
        }
        my $result = $module->verifySCCGuest($r, $c, $result);
        if (! $result)
        {
            $r->log_error("Guest verification failed\n");
            return (Apache2::Const::FORBIDDEN,
                 "Guest verification failed repository access denied");
        }
    }

    my $statement = sprintf("INSERT INTO Clients (GUID, HOSTNAME, TARGET, NAMESPACE, SECRET, REGTYPE)
                             VALUES (%s, %s, %s, %s, %s, 'SC')",
                             $dbh->quote($result->{login}),
                             $dbh->quote($hostname),
                             $dbh->quote($target),
                             $dbh->quote($namespace),
                             $dbh->quote($result->{password}));
    $r->log->info("STATEMENT: $statement");
    eval
    {
        $dbh->do($statement);
    };
    if ($@)
    {
        $r->log_error("DBERROR: ".$dbh->errstr);
    }

    _storeMachineData($r, $dbh, $result->{login}, $c);

    return (Apache2::Const::OK, $result);
}

#
# the handler for requests to the jobs ressource
#
sub subscriptions_handler($$$$)
{
    my $r   = shift || return undef;
    my $dbh = shift || return undef;
    my $cfg = shift || return undef;
    my $apiVersion = shift || return undef;
    my $path = sub_path($r);

    # map the requests to the functions
    if    ( $r->method() =~ /^GET$/i )
    {
        $r->log->error("GET request to the jobs interface. This is not supported.");
        return undef;
    }
    elsif ( $r->method() =~ /^POST$/i )
    {
        if ( $path =~ /^subscriptions\/systems\/?$/ && ($apiVersion > 1))
        {
            $r->log->info("POST connect/subscriptions/systems (announce)");
            my $c = JSON::decode_json(read_post($r));
            return announce($r, $dbh, $cfg, $c);
        }
        else { return undef; }
    }
    elsif ( $r->method() =~ /^PUT$/i )
    {
        # This request type is not (yet) supported
        # POSTing to the "jobs" interface (which is only used by smt-clients) means "creating a job"
        # It may be implemented later for the "clients" interface (which is for administrator usage).
        $r->log->error("PUT request to the jobs interface. This is not supported.");
        return undef;
    }
    elsif ( $r->method() =~ /^DELETE$/i )
    {
        # This request type is not (yet) supported
        # DELETEing to the "jobs" interface (which is only used by smt-clients) means "deleting a job"
        # It may be implemented later for the "clients" interface (which is for administrator usage).
        $r->log->error("DELETE request to the jobs interface. This is not supported.");
        return undef;
    }
    else
    {
        $r->log->error("Unknown request to the jobs interface.");
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
    my $cfg = undef;

    my $apiVersion = SMT::Utils::requestedAPIVersion($r);
    if (not $apiVersion)
    {
        return respond_with_error($r, Apache2::Const::HTTP_NOT_ACCEPTABLE, "API version not supported") ;
    }
    $r->err_headers_out->add('scc-api-version' => "v$apiVersion");

    # try to connect to the database - else report server error
    my $dbh = undef;
    if ( ! ($dbh=SMT::Utils::db_connect()) )
    {
        $r->log->error("RESTService could not connect to database.");
        return Apache2::Const::SERVER_ERROR;
    }
    eval
    {
        $cfg = SMT::Utils::getSMTConfig();
    };
    if($@ || !defined $cfg)
    {
        $r->log_error("Cannot read the SMT configuration file: ".$@);
        return ( Apache2::Const::SERVER_ERROR, "SMT server is missconfigured. Please contact your administrator.");
    }

    $r->log->info("$path called with API version $apiVersion");
    if ( $path =~ qr{^subscriptions?}    )
    {
        $r->log->info("call sunscription handler");
        ($code, $data) = subscriptions_handler($r, $dbh, $cfg, $apiVersion); }

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

    # return a 200 response
    return Apache2::Const::OK;
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

