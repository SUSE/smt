package SMT::Client::exampleVerify;

use strict;
use warnings;

use Apache2::RequestRec ();
use Apache2::RequestIO ();

sub verifyGuest {

    my $self    = shift;
    my $r       = shift;
    my $regroot = shift;
    # Insert code to connect to cloud framework and verify the guest
    # return 1 for successful verification, undef for verification failure
    # $r -> the request, i.e an Apache request object
    #       http://perl.apache.org/docs/2.0/api/Apache2/RequestRec.html
    # $regroot ->  HASHREF containing information sent by the client.
    return 1;
}

sub verifySCCGuest {

    my $self     = shift;
    my $r        = shift;
    my $clntData = shift;
    my $result   = shift;
    # Insert code to connect to cloud framework and verify the guest
    # return the result HASHREF for successful verification, undef for
    # verification failure
    # $r -> the request, i.e an Apache request object
    #       http://perl.apache.org/docs/2.0/api/Apache2/RequestRec.html
    # $clntData -> data received from the client
    # $result -> HASHREF of results of various previous operations
    return $result;
}

1;
