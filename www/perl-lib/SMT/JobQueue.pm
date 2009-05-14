#!/usr/bin/perl
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
#       xmlformat (default false)
sub getJob
{
  my ( $id, $xmlformat ) = @_;

  #TODO: read values from database
  my $type = "softwarepush";
  my $args =
  "<arguments>
    <force>true</force>
    <packages>
     <package>xterm</package>
     <package>yast2</package>
     <package>firefox</package>
    </packages>
  </arguments>";

  my $job = new Job( $id, $type, $args );

  return defined ( $xmlformat ) ? $job->asXML() : $job;
}


###############################################################################
# getNextJobID 
# returns the jobid of the next job either in xml format
# or in hash structure
# if no clientID is passed jobs for all clients are taken
#
# args: clientID 
#       xmlformat (default false)
sub getNextJobID
{
  my ( $clientID, $xmlformat ) = @_;

  #TODO: read next jobid from database
  my $id = 42;

  return defined ( $xmlformat ) ? "<job id=\"$id\">" : $id;
}


###############################################################################
# returns a list of next jobs either in xml format
# or in hash structure
# if no clientID is passed jobs for all clients are taken
sub getJobList
{
  my ( $clientID, $xmlformat ) = @_;

  #TODO: retrieve job list from database
  my @joblist = (12,23,42,55);

  if ( defined ( $xmlformat ) )
  {
    my $xml = "<jobs>\n";
    foreach my $jobid ( @joblist )
    {
      $xml .= " <job id=\"$jobid\">\n";
    }
    $xml .= "</jobs>";
    return $xml;
  }
  else
  {
    return @joblist;
  }
}


###############################################################################
# returns a list of next jobs either in xml format
# or in hash structure
# if no clientID is passed jobs for all clients are taken
#
sub addJob
{
  my $arg = shift;
  my $jobobject;

  if ( isa ($arg, 'HASH' ))
  {
    $jobobject = $arg;
  }
  else
  {
    $jobobject = new Job ( $arg );
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
sub deleteJob
{
  my $jobid = shift;

  #delte job from database

  return 1;
};



###############################################################################
# writes error line to log
# returns undef because that is passed to the caller
sub error
{
  my $message = shift;
  print "$message\n";
  return undef;
}


#my $job = new Job ('<job id="42" type="softwarepush"><arguments></arguments></job>');
#my $job = new Job (42, "swpush", { 'packages' => [ { 'package' => [ 'xterm', 'yast2', 'firefox' ] } ], 'force' => [ 'true' ] });
#print $job->getArgumentsXML();
