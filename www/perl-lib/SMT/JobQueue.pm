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

  my $guid      = shift || return undef;
  my $jobid     = shift;
  my $xmlformat = shift || 0;


  if ( ! defined getJob($self, $guid, $jobid, 0)  )
  { 
    return $xmlformat ? "<job/>" : undef;
  }

  my $sql = 'update JobQueue as j left join Clients as c on ( j.GUID_ID = c.ID )'.
	' set j.RETRIEVED = "'. SMT::Utils::getDBTimestamp().'"'.
	' where j.ID = '.$self->{dbh}->quote($jobid).
	' and c.GUID = '.$self->{dbh}->quote($guid);
 
  $self->{dbh}->do($sql) || return undef;

  return getJob($self, $guid, $jobid, $xmlformat);
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
  # maps a job type NUMBER to a STRING representation
  $type = SMT::Job::JOB_TYPE->{$result->{TYPE}} if (defined SMT::Job::JOB_TYPE->{$result->{TYPE}});

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
     $sql .= " and ";
     $sql .= " ( TARGETED <= \"". SMT::Utils::getDBTimestamp() . "\"";
     $sql .= "  OR TARGETED IS NULL ) ";
     $sql .= " and ";
     $sql .= " ( EXPIRES > \"". SMT::Utils::getDBTimestamp() . "\"";
     $sql .= "  OR EXPIRES IS NULL ) ";

  $sql .= ' and Clients.GUID='.$self->{dbh}->quote($guid) if (defined $guid);
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
                   , xmldejq => '<?xml version="1.0" encoding="UTF-8" ?>'
           );
  }
  else
  {
    return @jobListCollect;
  }
}


###############################################################################
# add a job to the database (arg = jobobject)
sub addJobIntern($$)
{
  my $self = shift;
  my $job = shift;

  my $client = SMT::Client->new({ 'dbh' => $self->{dbh} });
  my $guidid = $client->getClientIDByGUID($job->guid) || return undef;


  my $sql = "insert into JobQueue ";
  my @sqlkeys = ();
  my @sqlvalues = ();
  
  my @attribs = qw( id parentid name description type status stdout stderr exitcode created targeted expires retrieved finished verbose timelag message success);


  # GUID
  push ( @sqlkeys, "GUID_ID" );
  push ( @sqlvalues, $guidid );

  foreach my $attrib (@attribs)
  {
    if ( defined $job->{$attrib} )
    {
      push ( @sqlkeys, uc($attrib) );
      push ( @sqlvalues, $self->{dbh}->quote( $job->{$attrib} ));
    }
  }
  $sql .= " (". join  (", ", @sqlkeys ) .") " ;
  $sql .= " VALUES (". join  (", ", @sqlvalues ) .") " ;

  return $self->{dbh}->do($sql);
};


sub addJob($$)
{
  my $self = shift;
  my $job = shift;

  # if no jobid is defined we
  # must ask for the next available id
  if ( ! defined $job->{id} )
  {
    my ($id, $cookie) = getNextAvailableJobID($self);
    return undef if ( ! defined $id );
    return undef if ( ! defined $cookie );
    $job->id($id);
    addJobIntern($self, $job) || return undef;
    return deleteJobIDCookie($self, $id, $cookie);
  }
  else
  {
    addJobIntern($self, $job) || return undef;
  }
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
    addJob($self,$job) || return undef;
  }
  return 1;
}



###############################################################################
sub finishJob($)
{
  my $self = shift;
  my $guid      = shift || return undef;
  my $jobxml = shift;

  my $job = new SMT::Job( $self->{dbh}, "guiddummy", $jobxml );

  my $status ;
  if ( $job->success() eq "true")
  {
    $status = "1";  
  }
  else
  {
    $status = "2";  
  }

  my $sql = 'update JobQueue as j left join Clients as c on ( j.GUID_ID = c.ID )'.
	' set j.STDERR = '.$self->{dbh}->quote($job->stderr()).
	', j.MESSAGE = '.$self->{dbh}->quote($job->message()). 
	', j.STDOUT = '.$self->{dbh}->quote($job->stdout()).
	', j.EXITCODE = '.$self->{dbh}->quote($job->exitcode()).
	', j.STATUS = '.$self->{dbh}->quote($status).
	', j.FINISHED = "'. SMT::Utils::getDBTimestamp().'"'.

	' where j.ID = '.$self->{dbh}->quote($job->id()).
	' and c.GUID = '.$self->{dbh}->quote($guid);

  return $self->{dbh}->do($sql);
};

sub deleteJob($)
{
  my $self = shift;
  my $jobid = shift || return undef;

  #delte job from database

  return 1;
};


sub getNextAvailableJobID()
{
  my $self = shift;

  my $cookie = SMT::Utils::getDBTimestamp()." - ".rand(1024);

  # TODO: for cleanup 
  # TODO: add expires = today + 1day
  # TODO: add status or type undefined

  my $sql1 = 'insert into JobQueue ( DESCRIPTION ) values ("'.$cookie.'")' ;
  $self->{dbh}->do($sql1) || return ( undef, $cookie);

  my $sql2 = 'select ID from JobQueue '; 
     $sql2 .= ' where DESCRIPTION  = "'.$cookie.'"';

  my $id = $self->{dbh}->selectall_arrayref($sql2)->[0]->[0];

  return ($id, $cookie);

}

sub deleteJobIDCookie()
{
  my $self   = shift;
  my $id     = shift;
  my $cookie = shift;

  my $sql = "delete from JobQueue where ID = '$id' and DESCRIPTION = '$cookie'" ;
  return $self->{dbh}->do($sql);
}








1;
