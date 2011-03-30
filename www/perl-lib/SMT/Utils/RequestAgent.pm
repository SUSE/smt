package SMT::Utils::RequestAgent;

#
# SMT::Utils::RequestAgent
#   Originally part of SMT::Utils.
#   It was taken out and into its own module file to prevent "subroutine redefined" errors.
#

use strict;
use warnings;

use LWP;
use LWP::UserAgent;

@SMT::Utils::RequestAgent::ISA = qw(LWP::UserAgent);

sub new
{
    my($class, $puser, $ppass, %cnf) = @_;

    my $self = $class->SUPER::new(%cnf);

    bless {
           puser => $puser,
           ppass => $ppass
          }, $class;
}

sub get_basic_credentials
{
    my($self, $realm, $uri, $proxy) = @_;

    if($proxy)
    {
        if(defined $self->{puser} && defined $self->{ppass})
        {
            return ($self->{puser}, $self->{ppass});
        }
    }
    return (undef, undef);
}

1;
