package NU::SMTAuth;

use strict;
use warnings;
use SMT::Utils;
use Data::Dumper;

use Apache2::Const -compile => qw(OK SERVER_ERROR HTTP_UNAUTHORIZED FORBIDDEN AUTH_REQUIRED);


sub handler {
    my $r = shift;

    my $requiredAuth = "none";
    my $cfg = undef;
    my $requestedPath = $r->uri();

    eval
    {
        $cfg = SMT::Utils::getSMTConfig();
    };
    # ignore errors
    if(defined $cfg)
    {
        $requiredAuth = $cfg->val('LOCAL', 'requiredAuthType');
        $requiredAuth = "none" if(!defined $requiredAuth || $requiredAuth eq "");
    }
    if($requiredAuth ne "none" && $requiredAuth ne "lazy" && $requiredAuth ne "strict")
    {
        $requiredAuth = "none";
    }

    if($requiredAuth eq "none" && substr($requestedPath, -13) ne 'repoindex.xml')
    {
        $r->log->info("No auth required");
        return Apache2::Const::OK;
    }

    my ($status, $password) = $r->get_basic_auth_pw;
    return $status unless $status == Apache2::Const::OK;

    if( substr($requestedPath, -13) eq 'repoindex.xml' )
    {
        if ( $r->user eq "" )
        {
            $r->note_basic_auth_failure;
            #return Apache2::Const::HTTP_UNAUTHORIZED;
            return Apache2::Const::AUTH_REQUIRED;
        }

        # check for mirrorUser first
        if (defined $cfg && $cfg->val('LOCAL', 'mirrorUser') && $r->user eq $cfg->val('LOCAL', 'mirrorUser'))
        {
            if (! $cfg->val('LOCAL', 'mirrorPassword') eq $password)
            {
                $r->log->error("Bad password from mirrorUser: ".$r->user()." trying to access: $requestedPath");
                $r->note_basic_auth_failure;
                return Apache2::Const::AUTH_REQUIRED;
            }

            $r->log->info("Access granted for mirrorUser: ".$r->user().".");
        }

        # no better check required for repoindex.xml
        # if the user is not valid, he get an empty index file
        return Apache2::Const::OK;
    }

    #
    # ok, we need to check the credentials
    #

    my $dbh = undef;

    eval
    {
        $dbh = SMT::Utils::db_connect($cfg);
    };
    if($@ || ! defined $dbh)
    {
        $r->log->error("Cannot connect to database");
        return Apache2::Const::SERVER_ERROR;
    }
    my $sth = $dbh->prepare("SELECT guid, client_target,
                                    localpath, repository_target
                               FROM ClientRepositories
                               WHERE guid = :guid
                                 AND secret = :secret");
    $sth->execute_h(guid => $r->user, secret => $password);
    my $cdata = $sth->fetchall_hashref(["guid", "localpath"]);

    if( !$cdata || !exists $cdata->{$r->user} )
    {
        $r->log->error( "Invalid user: ".$r->user() );
        $r->note_basic_auth_failure;
        return Apache2::Const::AUTH_REQUIRED;
    }

    if($requiredAuth eq "lazy" )
    {
        $r->log->info("Access granted");
        return Apache2::Const::OK;
    }

    #
    # credentials ok, now we need to check if this user should have
    # access to the requested URI
    #

    # evil things like "dir/../../otherdir" are solved by apache.
    # we get here the resulting path
    # we only need to strip out "somedir////nextdir"
    $requestedPath = SMT::Utils::cleanPath("/", $requestedPath);

    $r->log->info($r->user()." requests path '$requestedPath'");

    foreach my $path ( keys %{$cdata->{$r->user}} )
    {
        if ($cdata->{$r->user}->{$path}->{client_target} &&
            $cdata->{$r->user}->{$path}->{repository_target} &&
            $cdata->{$r->user}->{$path}->{client_target} ne
                $cdata->{$r->user}->{$path}->{repository_target})
        {
            next;
        }

        $path = SMT::Utils::cleanPath("/repo", $path);

        $r->log->info($r->user()." has access to '$path'");

        if( index($requestedPath, $path) == 0 )
        {
            $r->log->info("Access granted");
            return Apache2::Const::OK;
        }
    }

    $r->log->error("FORBIDDEN: User: ".$r->user()." tried to access: $requestedPath");
    $r->note_basic_auth_failure;
    return Apache2::Const::FORBIDDEN;
}
1;
