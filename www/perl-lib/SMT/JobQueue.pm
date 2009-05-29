package SMT::JobQueue;

use strict;
use warnings;
use XML::Simple;
use UNIVERSAL 'isa';
use SMT::Job;
use SMT::Utils;
use Data::Dumper;


###############################################################################
# getJob 
# returns the job description for job $id either in xml format
# or in hash structure
# args: jobid 
# args: guid
#       xmlformat (default false)
sub getJob($$$)
{
  my $class     = shift;
  my $guid      = shift || return undef;
  my $jobid     = shift || return undef;
  my $xmlformat = shift || 0;

  my $dbh = SMT::Utils::db_connect();
  if ( !$dbh )
  {
    # TODO  log error: "Cannot connect to database";
    die "Please contact your administrator.";
  }

  my $sql = "select Clients.GUID, JobQueue.ID jid, TYPE, ARGUMENTS from JobQueue inner join Clients on ( JobQueue.GUID_ID = Clients.ID ) where JobQueue.ID =$jobid"; 
  $sql .= " and Clients.GUID = \"$guid\" " if (defined $guid);

  my $result = $dbh->selectall_hashref($sql, "jid")->{$jobid};

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

  my $job = new SMT::Job( $result->{GUID}, $result->{jid}, $type, $result->{ARGUMENTS} );
 
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
sub getNextJobID($$)
{
  my $class     = shift;
  my $guid      = shift;
  my $xmlformat = shift || 0;

  my $dbh = SMT::Utils::db_connect();
  if ( !$dbh )
  {
    # TODO  log error: "Cannot connect to database";
    die "Please contact your administrator.";
  }

  my $sql = "select JobQueue.ID jid from JobQueue inner join Clients on ( JobQueue.GUID_ID = Clients.ID ) "; 
  $sql .= " where STATUS   = " . 0				 ;          #( =not yet worked on)
#  $sql .= " and   TARGETED <= \"". SMT::Utils::getDBTimestamp() . "\"";
#  $sql .= " and   EXPIRES  >  \"". SMT::Utils::getDBTimestamp() . "\"";

  $sql .= " and Clients.GUID = \"$guid\"" if (defined $guid);

  my $id = $dbh->selectall_arrayref($sql)->[0]->[0];

  if ( defined $id)
  {
    return $xmlformat ? "<job id=\"$id\">" : $id;
  }
  else
  {
    return $xmlformat ? "<job/>" : undef;
  }

}


###############################################################################
# returns a list of next jobs either in xml format
# or in hash structure
# if no guid is passed jobs for all clients are taken
sub getJobList($$)
{
  my $class     = shift;
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
         push( @jobListCollect,  SMT::JobQueue->getJob($guid, $jobid, 0) );
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
  my $class = shift;
  my $arg = shift;
  my $jobobject;

  if ( isa ($arg, 'HASH' ))
  {
    $jobobject = $arg;
  }
  else
  {
    $jobobject = new SMT::Job ( $arg );
  }

  #TODO: write job to database

  print $jobobject->getId();

  return 1;
};


###############################################################################
# returns a list of next jobs either in xml format
# or in hash structure
# if no clientID is passed jobs for all clients are taken
#
sub deleteJob($)
{
  my $class = shift;
  my $jobid = shift || return undef;

  #delte job from database

  return 1;
};



###############################################################################
# writes error line to log
# returns undef because that is passed to the caller
#sub error($)
#{
#  my $class   = shift;
#  my $message = shift;
#  print "$message\n";
#  return undef;
#}


#my $job = new Job ('<job id="42" type="softwarepush"><arguments></arguments></job>');
#my $job = new Job (42, "swpush", { 'packages' => [ { 'package' => [ 'xterm', 'yast2', 'firefox' ] } ], 'force' => [ 'true' ] });
#print $job->getArgumentsXML();

1;
