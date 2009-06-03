package SMT::Config;

use strict;
use warnings;

use constant {
    REINIT_AFTER => 1024,
};

use SMT::CLI;

my $self = {};

sub init {
    $self = { counter => 0 };
    ($self->{cfg}, $self->{dbh}, $self->{nuri}) = SMT::CLI::init();
}

sub config {
    # Reset after 'REINIT_AFTER' calls
    $self = {} if (defined $self->{counter} && $self->{counter} >= REINIT_AFTER);

    # Initialize if not initialized
    init() if (! defined $self->{counter});

    ++$self->{counter};
    return $self;
}

1;
