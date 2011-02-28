package SMT::Job::Result;

use strict;
use warnings;
use UNIVERSAL 'isa';

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

  # TODO: does the check for cacheresult need to go here?
  my $sql = 'insert into JobResults (CLIENT_ID, JOB_ID, RESULT, CHANGED ) values (';
  $sql .= $self->{dbh}->quote($client_id).', '.$self->{dbh}->quote($job_id).', '.$self->{dbh}->quote($result).', now()';
  $sql .= ' ) on duplicate key update';
  my $res = $self->{dbh}->do($sql);
  return $res ? 1:0;
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
