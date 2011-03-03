package SMT::Job::Result;

use strict;
use warnings;
use UNIVERSAL 'isa';

use SMT::Utils;

use constant {
    VBLEVEL     => LOG_ERROR|LOG_WARN|LOG_INFO1|LOG_INFO2|LOG_DEBUG|LOG_DEBUG2,
};

sub new ($$)
{
  my $class = shift;
  my $params = shift || {};

  my $self = {};

  if (defined $params->{dbh})
  {
      $self->{dbh} = $params->{dbh};
  }

  if (defined $params->{LOG})
  {
      $self->{LOG} = SMT::Utils::openLog ($params->{LOG});
  }

  bless $self, $class;
  return $self;
}

###############################################################################
# saveResult
#   Save the result XML of a job (in XML)
# Arguments
#   client_id : the id of the client system (Note: this is NOT the GUID!!)
#   job_id    : the id of the job
#   result    : the plain XML answer from the smt-client
#
sub saveResult($$$$)
{
  my $self      = shift || return undef;
  my $client_id = shift || return undef;
  my $job_id    = shift || return undef;
  my $result    = shift || return undef;

  my $sth = $self->{dbh}->prepare('insert into JobResults (CLIENT_ID, JOB_ID, RESULT, CHANGED ) values (?, ?, ?, now() ) on duplicate key update RESULT=?, CHANGED=now()');
  $sth->bind_param(1, $client_id );
  $sth->bind_param(2, $job_id );
  $sth->bind_param(3, $result );
  $sth->bind_param(4, $result );
  my $cnt = $sth->execute;

  SMT::Utils::printLog($self->{LOG}, VBLEVEL, LOG_ERROR, 'Database error: '.$self->{dbh}->errstr() ) if $@;
  return $cnt ? 1:0;
}

sub getResult($$$)
{
  # TODO
  return 1;
}

sub getResultsByClientID($$)
{
  # TODO
  return 1;
}

sub getResultsByJobID($$)
{
  # TODO
  return 1;
}

1;
