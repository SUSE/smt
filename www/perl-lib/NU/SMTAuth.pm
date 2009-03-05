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
        #
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
    
    my $statement = sprintf("SELECT SECRET from Clients where GUID = %s and SECRET = %s",
                            $dbh->quote($r->user()), $dbh->quote($password));
    my $existsecret = $dbh->selectcol_arrayref($statement);
    
    if( !exists $existsecret->[0] || !defined $existsecret->[0] || $existsecret->[0] eq "" )
    {
                            
        # Fallback to MachineData: secret in the clients table is very new and might be empty
        $statement = sprintf("SELECT GUID from MachineData where GUID = %s and KEYNAME = 'secret' and VALUE = %s",
                             $dbh->quote($r->user()), $dbh->quote($password));
        my $existuser = $dbh->selectcol_arrayref($statement);

        if( !exists $existuser->[0] || !defined $existuser->[0] || $existuser->[0] ne $r->user() )
        {
            $r->log->error( "Invalid user: ".$r->user() );
            $r->note_basic_auth_failure;
            return Apache2::Const::AUTH_REQUIRED;
        }
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

    $statement = sprintf("select GUID, TARGET, NAMESPACE from Clients c where c.GUID=%s", $dbh->quote($r->user()) );
    my $cdata = $dbh->selectall_hashref($statement, "GUID");

    $statement  = " select c.LOCALPATH from Catalogs c, ProductCatalogs pc, Registration r ";
    $statement .= sprintf(" where r.GUID=%s ", $dbh->quote($r->user()) );
    $statement .= " and r.PRODUCTID=pc.PRODUCTDATAID and c.CATALOGID=pc.CATALOGID and c.DOMIRROR like 'Y' ";
    # add a filter by target architecture if it is defined
    if (exists $cdata->{$r->user()}->{TARGET} && defined $cdata->{$r->user()}->{TARGET} &&
        $cdata->{$r->user()}->{TARGET} ne "" )
    {
        $statement .= sprintf(" and c.TARGET=%s", $dbh->quote( $cdata->{$r->user()}->{TARGET} ));
    }

    # evil things like "dir/../../otherdir" are solved by apache.
    # we get here the resulting path
    # we only need to strip out "somedir////nextdir"
    $requestedPath = SMT::Utils::cleanPath("/", $requestedPath);

    $r->log->info($r->user()." requests path '$requestedPath'");

    my $localRepoPath = $dbh->selectall_hashref($statement, 'LOCALPATH');
    foreach my $path ( keys %{$localRepoPath} )
    {
        if (exists $cdata->{$r->user()}->{NAMESPACE} && defined $cdata->{$r->user()}->{NAMESPACE} &&
            $cdata->{$r->user()}->{NAMESPACE} ne "" )
        {
            $path = SMT::Utils::cleanPath("/", $cdata->{$r->user()}->{NAMESPACE}, "repo", $path);
        }
        else
        {
            $path = SMT::Utils::cleanPath("/repo", $path);
        }
        
        
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
