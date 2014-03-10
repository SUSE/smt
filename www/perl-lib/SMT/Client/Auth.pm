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
    else
    {
        return Apache2::Const::OK;
    }

## Alternative authentication via Client API
## if the fallback to MachineData gets implemented it might be unified
#
#    my $client = undef;
#    if ( ! ($client = SMT::Client->new({ 'dbh' => $dbh }) )
#    {
#        $r->log->error("RESTService could not create a Client Request Object.");
#        return Apache2::Const::SERVER_ERROR unless defined $client;
#    }

    # do authentication
#    my $auth = $client->authenticateByGUIDAndSecret($username, $password)
#    if ( $auth == {} )
#    {
#        $r->log->error("RESTService saw a login attempt with invalid credentials.");
#        return Apache2::Const::FORBIDDEN;
#    }
#    elsif ( keys %{$auth} == 1 )
#    {
#        my @keys = keys %{$auth};
#        my $first = shift(@keys);
#        if( not ( exists ${$auth}{$first}{'GUID'}  &&  ${$auth}{$first}{'GUID'} eq $username ) )
#        {
#            $r->log->error("RESTService prevented a login with a wrong username (GUID).");
#            return Apache2::Const::FORBIDDEN;
#        }
#    }
#    else
#    {
#        $r->log->error("RESTService encoutered a severe login error. A user that logged in was found twice in the database.");
#        return Apache2::Const::SERVER_ERROR;
#    }


}
1;
