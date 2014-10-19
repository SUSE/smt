package SMT::Client::Auth;

#
# Authentication handler for SMT RESTServices
#  is basically like NU::SMTAuth but with small changes (maybe unified in the future)
#

use strict;
use warnings;
use SMT::Utils;

use Apache2::Const -compile => qw(OK SERVER_ERROR HTTP_UNAUTHORIZED FORBIDDEN AUTH_REQUIRED);


sub handler {
    my $r = shift;

    my $cfg = undef;
    eval  {  $cfg = SMT::Utils::getSMTConfig();  };
    if ( $@ || ! defined $cfg )
    {
        $r->log_error("Cannot read the SMT configuration file: ".$@);
        return Apache2::Const::SERVER_ERROR;
    }

    my ($status, $password) = $r->get_basic_auth_pw;
    return $status unless $status == Apache2::Const::OK;

    if ( not defined $r->user  ||  $r->user eq '' )
    {
        $r->note_basic_auth_failure;
        return Apache2::Const::AUTH_REQUIRED;
    }

    my $dbh = undef;

    eval  {  $dbh = SMT::Utils::db_connect($cfg);  };
    if($@ || ! defined $dbh)
    {
        $r->log->error("Cannot connect to database");
        return Apache2::Const::SERVER_ERROR;
    }

    my $statement = sprintf("SELECT secret from Clients where guid = %s and secret = %s",
                            $dbh->quote($r->user()), $dbh->quote($password));
    my $existsecret = $dbh->selectcol_arrayref($statement);

    if( !exists $existsecret->[0] || !$existsecret->[0])
    {
        # connect/system requires a system authentication
        # generic REST authentication is not allowed here
        if ($r->path_info() !~ /\/systems\//)
        {

            # last chance of authentication: RESTAdmin - administrative access to all REST ressources
            my $restEnable = $cfg->val('REST', 'enableRESTAdminAccess');
            if ( defined $restEnable && $restEnable =~ /^1$/ )
            {
                my $RAU = $cfg->val('REST', 'RESTAdminUser');
                my $RAP = $cfg->val('REST', 'RESTAdminPassword');
                if ( defined $RAU  &&  defined $RAP  &&  $RAU eq $r->user()  &&  $RAP  eq  $password  &&  $RAP ne '' )
                {
                    return Apache2::Const::OK;
                }
            }
        }

        $r->log->error( "Invalid user: ".$r->user() );
        $r->note_basic_auth_failure;
        return Apache2::Const::AUTH_REQUIRED;
    }
    else
    {
        return Apache2::Const::OK;
    }
}
1;
