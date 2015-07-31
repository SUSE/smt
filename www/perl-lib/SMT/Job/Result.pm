package SMT::Job::Result;

use strict;
use warnings;

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

#
# getOneResult
#   Function to query just one result entry
#
# parameters
#   - job ID
#   - client ID
#   - configuration hash (see below)
#
sub getOneResult($$$;\%)
{
  my $self      = shift || return undef;
  my $job_id    = shift || return undef;
  my $client_id = shift || return undef;
  my $config    = shift || {};

  return $self->getResults([$job_id], [$client_id], $config);
}

#
# getResults
#   Generic function to query the job result data
#
# parameters
#   - array of job IDs
#   - array of client IDs (optional)
#   - configuration hash
#     supported flags
#     * asXML => 1         : return as XML snippet, also true if set to '' (compatiblility with JobQueue)
#     * checkupstream => 1 : only return data that is allowed to go upstream
#
sub getResults($\@;\@\%)
{
  my $self       = shift || return undef;
  my $job_ids    = shift || return undef;
  my $client_ids = shift || ();
  my $config     = shift || {};
  my @params = ();

  my $sql = 'select r.* from JobResults r inner join JobQueue j on (r.CLIENT_ID = j.GUID_ID and r.JOB_ID = j.ID) where ';
  $sql .= ' j.UPSTREAM = 1 and ' if ( UNIVERSAL::isa($config, 'HASH') && (exists $config->{checkupstream}) && ($config->{checkupstream} == 1) );

  return undef unless ( UNIVERSAL::isa($job_ids, 'ARRAY') && scalar @$job_ids );
  my $jq = ' ?,' x scalar @$job_ids;
  $jq =~ s/,$//;
  $sql .= ' r.JOB_ID in ('.$jq.') ';
  push @params, @$job_ids;

  if ( UNIVERSAL::isa($client_ids, 'ARRAY') && scalar @$client_ids )
  {
      my $cq = ' ?,' x scalar @$client_ids;
      $cq =~ s/,$//;
      $sql .= ' and  r.CLIENT_ID in ('.$cq.') ';
      push @params, @$client_ids;
  }

  my $ref = $self->{dbh}->selectall_arrayref( $sql, { Columns => {} }, @params );

  return $self->asResultsXML($ref) if (defined $config->{asXML} && ($config->{asXML} =~ /^1$/ || $config->{asXML} eq ''));
  return $ref || undef;
}


#
# asResultsXML
#   Internal helper function that transforms the result data into an XML snippet
#    that can be transmitted via the report job
# parameters:
#   - the return of the function getResults()
#
sub asResultsXML($$)
{
  my $self = shift || return undef;
  my $res  = shift || return undef;

  my $xml = "<results>\n";
  if ( UNIVERSAL::isa($res, 'HASH') )
  {
      $xml .= ($res->{RESULT}."\n") if defined $res->{RESULT};
  }
  elsif ( UNIVERSAL::isa($res, 'ARRAY') )
  {
      foreach my $href (@$res)
      {
          $xml .= ($href->{RESULT}."\n") if ( UNIVERSAL::isa($href, 'HASH') || defined $href->{RESULT} );
      }
  }

  $xml .= "\n</results>";
  return $xml;
}


1;
