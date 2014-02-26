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
    return 1;
}

1;
