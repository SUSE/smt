package SMT::JobQueue;

use strict;
use warnings;
use XML::Simple;
use UNIVERSAL 'isa';
use SMT::Job;
use SMT::Utils;
use Data::Dumper;

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
# getJob 
# returns the job description for job $id either in xml format
# or in hash structure
# args: jobid 
# args: guid
#       xmlformat (default false)
sub getJob($$$$)
{
  my $self      = shift;

  my $guid      = shift;
  my $jobid     = shift;
  my $xmlformat = shift || 0;

  if ( ! defined $jobid )
  {
    return $xmlformat ? "<job/>" : undef;

  }

  my $sql = 'select Clients.GUID, JobQueue.ID as jid, TYPE, ARGUMENTS '.
    'from JobQueue inner join Clients on ( JobQueue.GUID_ID = Clients.ID ) '.
    'where JobQueue.ID='.$self->{'dbh'}->quote($jobid);

  $sql .= ' and Clients.GUID='.$self->{'dbh'}->quote($guid).' ' if (defined $guid);

  my $result = $self->{'dbh'}->selectall_hashref($sql, 'jid')->{$jobid};

  if ( ! defined $result )
  {
    return $xmlformat ? "<job/>" : undef;
  }

  my $type = "unknown";
  $type = "patchstatus"  if ( $result->{TYPE} == 1);
  $type = "softwarepush" if ( $result->{TYPE} == 2);
  $type = "update"       if ( $result->{TYPE} == 3);
  $type = "execute"      if ( $result->{TYPE} == 4);
  $type = "reboot"       if ( $result->{TYPE} == 5);
  $type = "configure"    if ( $result->{TYPE} == 6);
  $type = "wait"         if ( $result->{TYPE} == 7);

  my $job = SMT::Job->new({ 'dbh' => $self->{dbh} });
  $job->newJob( $result->{GUID}, $result->{jid}, $type, $result->{ARGUMENTS} );
 
  return $xmlformat ? $job->asXML() : $job;
}


###############################################################################
# getNextJobID 
# returns the jobid of the next job either in xml format
# or in hash structure
# if no guid is passed jobs for all clients are taken
#
# args: guid 
#       xmlformat (default false)
sub getNextJobID($$$)
{
  my $self      = shift;

  my $guid      = shift;
  my $xmlformat = shift || 0;

  my $sql = 'select JobQueue.ID jid from JobQueue inner join Clients on ( JobQueue.GUID_ID = Clients.ID ) '; 
     $sql .= ' where STATUS  = ' . 0				 ;          #( =not yet worked on)
#    $sql .= " and   TARGETED <= \"". SMT::Utils::getDBTimestamp() . "\"";
#    $sql .= " and   EXPIRES  >  \"". SMT::Utils::getDBTimestamp() . "\"";

  $sql .= ' and Clients.GUID='.$self->{dbh}->quote($guid) if (defined $guid);

  my $id = $self->{dbh}->selectall_arrayref($sql)->[0]->[0];

  if ( defined $id)
  {
    return $xmlformat ? '<job id="'.$id.'">' : $id;
  }
  else
  {
    return $xmlformat ? '<job/>' : undef;
  }

}


###############################################################################
# returns a list of next jobs either in xml format
# or in hash structure
# if no guid is passed jobs for all clients are taken
sub getJobList($$)
{
  my $self      = shift;
  my $guid      = shift || return undef;
  my $xmlformat = shift || 0;

  #TODO: retrieve job list from database
  #TODO: test GUID

  # just create some test jobs
  my @joblist = (12, 34, 55);
  do {
    push @joblist, int(rand(200)+60);
  } while (scalar(@joblist) < 9);

  my @jobListCollect = ();

  if ( $xmlformat == 1 )
  {
     foreach my $jobid (@joblist)
     {
         push( @jobListCollect,  $self->getJob($guid, $jobid, 0) );
     }

     my $allJobs = {  'job' => [@jobListCollect]  };
     return XMLout( $allJobs 
                    , rootname => "jobs"
                    # , noattr => 1
                   , xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>'
           );
  }
  else
  {
    return @jobListCollect;
  }
}


###############################################################################
# returns a list of next jobs either in xml format
# or in hash structure
# if no clientID is passed jobs for all clients are taken
#
sub addJob($)
{
  my $self = shift;
  my $arg = shift;
  my $jobobject = SMT::Job->new({ dbh => $self->{dbh} });

  if ( isa ($arg, 'HASH' ))
  {
    $jobobject->addJob( $arg );
  }
  else
  {
    $jobobject->addJob( $arg );
  }

  #TODO: write job to database

  print $jobobject->getId();

  return 1;
};


sub updateJob($)
{
  my $self = shift;
  my $guid      = shift || return undef;
  my $jobxml = shift;

  my $job = new SMT::Job( $self->{dbh}, "guiddummy", $jobxml );

  my $status ;
  if ( $job->getSuccess() eq "true")
  {
    $status = "1";  
  }
  else
  {
    $status = "2";  
  }

  my $sql = 'update JobQueue as j left join Clients as c on ( j.GUID_ID = c.ID )'.
#  $sql .= " j.MESSAGE = \"". $job->getMessage() . "\"";	# TODO: where is message in daba
	' set j.STDERR = '.$self->{dbh}->quote($job->getStderr()).
	', j.STDOUT = '.$self->{dbh}->quote($job->getStdout()).
	', j.EXITCODE = '.$self->{dbh}->quote($job->getReturnValue()).
	', j.STATUS = '.$self->{dbh}->quote($status).

	' where j.ID = '.$self->{dbh}->quote($job->getId()).
	' and c.GUID = '.$self->{dbh}->quote($guid);

  return $self->{dbh}->do($sql);
};

###############################################################################
# returns a list of next jobs either in xml format
# or in hash structure
# if no clientID is passed jobs for all clients are taken
#
sub deleteJob($)
{
  my $self = shift;
  my $jobid = shift || return undef;

  #delte job from database

  return 1;
};



###############################################################################
# writes error line to log
# returns undef because that is passed to the caller
#sub error($)
#{
#  my $self   = shift;
#  my $message = shift;
#  return undef;
#}

1;
