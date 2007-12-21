package NU::YEPAuth;

use strict;
use warnings;

use Apache2::Const -compile => qw(OK SERVER_ERROR AUTH_REQUIRED);


sub handler {
    my $r = shift;

    # dummy authentication system
    # it just makes sure that authentication succeeds and username is set - no further checks

    my ($status, $password) = $r->get_basic_auth_pw;
    return $status unless $status == Apache2::Const::OK;

    if ( $r->user eq "" ) { return Apache2::Const::AUTH_REQUIRED; }

    return Apache2::Const::OK;
}
1;