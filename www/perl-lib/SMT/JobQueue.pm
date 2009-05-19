package SMT::JobQueue;

use strict;
use warnings;
use XML::Simple;
use UNIVERSAL 'isa';
use SMT::Job;


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

  #TODO: read values from database
  #TODO: check GUID
 
  my $type = "softwarepush";

  my $args =
  "<arguments>
    <force>true</force>
    <packages>";

  my @randomPackages = qw( xterm yast2-trans-ar yast2-trans-bn yast2-trans-ca yast2-trans-cy yast2-trans-da yast2-trans-de yast2-trans-pt pwgen whois );

  foreach my $pack (@randomPackages) 
  {
     $args .= "<package>"."$pack"."</package>" if int(rand(10)) > 5 ;
  }
  $args .= "<package>mmv</package>";
  $args .= " </packages>
  </arguments>";

  my $job = new SMT::Job( $guid, $jobid, $type, $args );

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
  my $guid      = shift || return undef;
  my $xmlformat = shift || 0;

  #TODO: read next jobid from database
  my $id = int(rand(500))+1;

  return  $xmlformat  ? "<job id=\"$id\">" : $id;
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
sub error($)
{
  my $class   = shift;
  my $message = shift;
  print "$message\n";
  return undef;
}


#my $job = new Job ('<job id="42" type="softwarepush"><arguments></arguments></job>');
#my $job = new Job (42, "swpush", { 'packages' => [ { 'package' => [ 'xterm', 'yast2', 'firefox' ] } ], 'force' => [ 'true' ] });
#print $job->getArgumentsXML();

1;
