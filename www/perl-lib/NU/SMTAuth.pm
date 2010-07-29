package NU::SMTAuth;

use strict;
use warnings;
use SMT::Utils;
use Data::Dumper;

use Apache2::Const -compile => qw(OK SERVER_ERROR HTTP_UNAUTHORIZED FORBIDDEN AUTH_REQUIRED);
use Log::Log4perl qw(get_logger :levels);

sub handler {
    my $r = shift;
    my $log = get_logger();
    
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
        $log->debug("No auth required");
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
        $log->error("Cannot connect to database");
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
        $log->debug("STATEMENT: $statement");
        my $existuser = $dbh->selectcol_arrayref($statement);

        if( !exists $existuser->[0] || !defined $existuser->[0] || $existuser->[0] ne $r->user() )
        {
            $log->error( "Invalid user: ".$r->user() );
            $r->note_basic_auth_failure;
            return Apache2::Const::AUTH_REQUIRED;
        }
    }
    
    if($requiredAuth eq "lazy" )
    {
        $log->debug("Access granted");
        return Apache2::Const::OK;
    }
    
    #
    # credentials ok, now we need to check if this user should have
    # access to the requested URI
    #

    $statement = sprintf("select GUID, TARGET, NAMESPACE from Clients c where c.GUID=%s", $dbh->quote($r->user()) );
    $log->debug("STATEMENT: $statement");
    my $cdata = $dbh->selectall_hashref($statement, "GUID");

    my $target = $cdata->{$r->user()}->{'TARGET'} if ($cdata->{$r->user()}->{'TARGET'});
    my $namespace = "";
    if(exists $cdata->{$r->user()}->{NAMESPACE} && defined $cdata->{$r->user()}->{NAMESPACE})
    {
      $namespace = $cdata->{$r->user()}->{NAMESPACE};
    }
    
    $statement = sprintf("SELECT PRODUCTID from Registration WHERE GUID=%s",$dbh->quote($r->user()));
    $log->debug("STATEMENT: $statement");
    my $pidarr = $dbh->selectcol_arrayref($statement);
    
    my $catalogs = SMT::Utils::findCatalogs( $dbh, $target, $pidarr,
                                             SMT::Utils::getGroupIDforGUID($dbh, $r->user()));
    
    # evil things like "dir/../../otherdir" are solved by apache.
    # we get here the resulting path
    # we only need to strip out "somedir////nextdir"
    $requestedPath = SMT::Utils::cleanPath("/", $requestedPath);

    $log->debug($r->user()." requests path '$requestedPath'");
    
    foreach my $cid ( keys %{$catalogs} )
    {
      my $path = $catalogs->{$cid}->{'LOCALPATH'};
      if($namespace ne "" && uc($catalogs->{$cid}->{STAGING}) eq "Y")
      {
        $path = SMT::Utils::cleanPath("/repo", $namespace, $path);
      }
      else
      {
        $path = SMT::Utils::cleanPath("/repo", $path);
      }
      
      $log->debug($r->user()." has access to '$path'");
      
      if( index($requestedPath, $path) == 0 )
      {
        $log->debug("Access granted");
        return Apache2::Const::OK;
      }
    }
    
    $log->error("FORBIDDEN: User: ".$r->user()." tried to access: $requestedPath");
    $r->note_basic_auth_failure;
    return Apache2::Const::FORBIDDEN;
}
1;
