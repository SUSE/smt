#!/usr/bin/perl
package SMT::Job;

use strict;
use warnings;
use Job;


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
#
sub getJobList
{
  my ( $clientID, $xmlformat ) = @_;

  #TODO: retrieve job list from database
  my @joblist = (12,23,42,55);

  if ( defined ( $xmlformat ) )
  {
    my $xml = "<joblist>\n";
    foreach my $jobid ( @joblist )
    {
      $xml .= " <job id=\"$jobid\">\n";
    }
    $xml .= "</joblist>";
    return $xml;
  }
  else
  {
    return @joblist;
  }
}

