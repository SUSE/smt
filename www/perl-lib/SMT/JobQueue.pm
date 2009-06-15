package SMT::JobQueue;

use strict;
use warnings;
use XML::Simple;
use UNIVERSAL 'isa';
use SMT::Job;
use SMT::Client;
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
# retriveJob 
# returns the job description for job $id either in xml format and stets the
# retrived date
# or in hash structure
# args: jobid 
# args: guid
#       xmlformat (default false)
sub retrieveJob($$$$)
{
  my $self      = shift;

  my $guid      = shift;
  my $jobid     = shift;
  my $xmlformat = shift || 0;

  my $job = SMT::Job->new({ 'dbh' => $self->{dbh} });
  $job->readJobFromDatabase( $jobid, $guid );

  if ( ! $job->isValid() )
  {
    return $xmlformat ? "<job/>" : undef;
  }

  $job->retrieved( SMT::Utils::getDBTimestamp() );
  $job->save();

  return $xmlformat ? $job->asXML() : $job;
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

  my $job = SMT::Job->new({ 'dbh' => $self->{dbh} });
  $job->readJobFromDatabase( $jobid, $guid );

  if ( ! $job->isValid() )
  {
    return $xmlformat ? "<job/>" : undef;
  }

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
     $sql .= ' where STATUS  = ' . 0				 ;          #( 0 = not yet worked on)
     $sql .= " and ";
     $sql .= " ( TARGETED <= \"". SMT::Utils::getDBTimestamp() . "\"";
     $sql .= "  OR TARGETED IS NULL ) ";
     $sql .= " and ";
     $sql .= " ( EXPIRES > \"". SMT::Utils::getDBTimestamp() . "\"";
     $sql .= "  OR EXPIRES IS NULL ) ";
     $sql .= " and ";
     $sql .= "  PARENT_ID IS NULL ";
     $sql .= ' and Clients.GUID='.$self->{dbh}->quote($guid) if (defined $guid);
     $sql .= " ORDER BY jid ";
     $sql .= ' limit 1';

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
  my @joblist = (44);
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
    return "@joblist";
  }
}


###############################################################################
# add a job to the database (arg = jobobject)
sub addJob($$)
{
  my $self = shift;
  my $job = shift;

  return $job->save();
}


# add jobs for multiple guids
# args: jobobject, guidlist
sub addJobForMultipleGUIDs
{
  my $self = shift;
  my $job = shift;
  my @guids = @_;

  foreach my $guid (@guids)
  {
    $job->guid($guid);
    $job->save() || return undef;
  }
  return 1;
}



sub calcNextTargeted
{
  my $self  = shift;
  my $guid  = shift || return undef;
  my $jobid = shift || return undef;

  my $client = SMT::Client->new({ 'dbh' => $self->{dbh} });
  my $guidid = $client->getClientIDByGUID($guid) || return undef;

  my $sql = 'select ADDTIME("'.SMT::Utils::getDBTimestamp().'", TIMELAG ) from JobQueue '; 
     $sql .= ' where GUID_ID  = '. $self->{dbh}->quote($guidid) ;
     $sql .= ' AND ID  = '. $self->{dbh}->quote($jobid) ;

  my $time = $self->{dbh}->selectall_arrayref($sql)->[0]->[0];

  return $time;

}


sub parentFinished
{
  my $self      = shift;

  my $guid      = shift;	
  my $jobid     = shift; 	#jobid of parent job
 
  my $client = SMT::Client->new({ 'dbh' => $self->{dbh} });
  my $guidid = $client->getClientIDByGUID($guid) || return undef;


  my $sql = 'update JobQueue'.
  ' set PARENT_ID  = NULL '.
  ' where PARENT_ID = '.$self->{dbh}->quote($jobid).
  ' and GUID_ID = '.$self->{dbh}->quote($guidid);

  $self->{dbh}->do($sql) || return undef;


}


###############################################################################
sub finishJob($)
{
  my $self = shift;
  my $guid      = shift || return undef;
  my $jobxml = shift;

  my $xmljob = SMT::Job->new({ 'dbh' => $self->{dbh} });
  $xmljob->readJobFromXML( $guid, $jobxml );

  my $job = SMT::Job->new({ 'dbh' => $self->{dbh} });
  $job->readJobFromDatabase( $xmljob->{id}, $xmljob->{guid} );

  return undef unless ( $job->{retrieved} );


  if ( $job->type() eq "patchstatus" )
  {
      my $client = SMT::Client->new( {'dbh' => $self->{'dbh'} });
      $client->updatePatchstatus( $guid, $xmljob->message() );
  }


  $job->stderr  ( $xmljob->stderr()   );
  $job->stdout  ( $xmljob->stdout()   );
  $job->exitcode( $xmljob->exitcode() );
  $job->message ( $xmljob->message()  );
  $job->status  ( $xmljob->status()   );
  $job->finished( SMT::Utils::getDBTimestamp );

  if ( $job->persistent() )
  {
    $job->targeted( calcNextTargeted($self, $guid, $job->{id}) );
    $job->status( 0 );
  }


  parentFinished($self, $guid, $job->{id} );

  return $job->save();

};

sub deleteJob($)
{
  my $self = shift;
  my $jobid = shift || return undef;

  #TODO: delete job from database

  return 1;
};




1;
