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
  # remove xml declaration from the result
  $result =~ s/^\s*<\?[xX][mM][lL][^>]*>[\s\n]*//;

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
  my $self      = shift || return undef;
  my $client_id = shift || return undef;
  my $job_id    = shift || return undef;

  my $rh = $self->{dbh}->selectrow_hashref('select * from JobResults where CLIENT_ID = ? and JOB_ID = ?', { Columns => {} }, ($client_id, $job_id) );
  return $rh || undef;
}

sub getResultsByClientID($$)
{
  my $self      = shift || return undef;
  my $client_id = shift || return undef;

  my $rh = $self->{dbh}->selectall_arrayref('select * from JobResults where CLIENT_ID = ?', { Columns => {} }, $client_id );
  return $rh || undef;
}

sub getResultsByJobID($$)
{
  my $self   = shift || return undef;
  my $job_id = shift || return undef;

  my $rh = $self->{dbh}->selectall_arrayref('select * from JobResults where JOB_ID = ?', { Columns => {} }, $job_id );
  return $rh || undef;
}

#
# getResultsXMLByJobID
#
#   create the full XML <results> snippet to be raw copied into a result job reply
#
sub getResultsXMLByJobID($$)
{
  my $self   = shift || return undef;
  my $job_id = shift || return undef;

  my $arrayref = $self->getResultsByJobID($job_id);
  return undef unless isa($arrayref, 'ARRAY');

  my $xml="<results>\n";

  foreach my $ref ($arrayref)
  {
      $xml .= ($ref->{RESULT}."\n") if ( isa($ref, 'HASH') && defined $ref->{RESULT} );
  }
  $xml .= "\n</results>";
  return $xml;
}


1;
