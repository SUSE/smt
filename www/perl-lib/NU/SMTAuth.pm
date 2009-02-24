package NU::SMTAuth;

use strict;
use warnings;
use SMT::Utils;

use Apache2::Const -compile => qw(OK SERVER_ERROR AUTH_REQUIRED);


sub handler {
    my $r = shift;

    my $requiredAuth = "none";
    my $cfg = undef;
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

    if($requiredAuth eq "none" && substr($r->uri(), -13) ne 'repoindex.xml')
    {
        #$r->log->info("No auth required");
        return Apache2::Const::OK;
    }

    my ($status, $password) = $r->get_basic_auth_pw;
    return $status unless $status == Apache2::Const::OK;

    if( substr($r->uri(), -13) eq 'repoindex.xml' )
    {
        if ( $r->user eq "" ) { return Apache2::Const::AUTH_REQUIRED; }
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
    
    # FIXME: we should move "secret" into the client table and do the check there
    my $statement = sprintf("SELECT GUID from MachineData where GUID = %s and KEYNAME = 'secret' and VALUE = %s",
                            $dbh->quote($r->user()), $dbh->quote($password));
    my $existuser = $dbh->selectcol_arrayref($statement);

    if( !exists $existuser->[0] || !defined $existuser->[0] || $existuser->[0] ne $r->user() )
    {
        $r->log->error( "Invalid user: ".$r->user() );
        return Apache2::Const::AUTH_REQUIRED;
    }

    if($requiredAuth eq "lazy" )
    {
        return Apache2::Const::OK;
    }
    
    #
    # credentials ok, now we need to check if this user should have
    # access to the requested URI
    #

    my $targetselect = sprintf("select TARGET from Clients c where c.GUID=%s", $dbh->quote($r->user()) );
    my $target = $dbh->selectcol_arrayref($targetselect);

    my $statement = " select c.LOCALPATH from Catalogs c, ProductCatalogs pc, Registration r ";
    $catalogselect   .= sprintf(" where r.GUID=%s ", $dbh->quote($r->user()) );
    $catalogselect   .= " and r.PRODUCTID=pc.PRODUCTDATAID and c.CATALOGID=pc.CATALOGID and c.DOMIRROR like 'Y' ";
    # add a filter by target architecture if it is defined
    if (defined $target && defined ${$target}[0] )
    {
        $catalogselect .= sprintf(" and c.TARGET=%s", $dbh->quote( ${$target}[0] ));
    }

    my $localRepoPath = $dbh->selectall_arrayref($statement);
    foreach my $path ( @{$localRepoPath} )
    {
        if( index($r->uri(), $path) >= 0 )
        {
            return Apache2::Const::OK;
        }
    }

    $r->log->error("FORBIDDEN: User: ".$r->user()." tried to access: ".$r->uri());
    return Apache2::Const::FORBIDDEN;
}
1;
