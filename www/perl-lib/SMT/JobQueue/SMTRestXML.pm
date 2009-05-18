#!/usr/bin/env perl
use strict;
use warnings;
package SMTRestXML;
use HTTP::Request;
use HTTP::Request::Common;
use LWP::UserAgent;
use XML::Simple;
use Data::Dumper;
use UNIVERSAL 'isa';
use SMTConstants;
use SMTConfig;
use SMTUtils;




##############################################################################          
# exit with error                                                                        
# args: message, jobid                                                                   
sub error                                                                                
{                                                                                        
  my ( $message, $jobid ) =  @_;                                                         
                                                                                         
  if ( defined ($jobid ) )                                                               
  {                                                                                      
    SMTUtils::logger ("let's tell the server that $jobid failed");                                 
    updatejob ( $jobid, "false", $message );                                             
  }                                                                                      
  SMTUtils::logger ("ERROR: $message", $jobid);                                 
  die "Error: $message\n";                                                               
};                                                                                       
                                                                                         
                                                                                         

###############################################################################
# updates status of a job on the smt server
# args: jobid, success, message 
sub updatejob
{
  return;
  my ($jobid, $success, $message, $stdout, $stderr, $returnvalue) =  @_;

  SMTUtils::logger( "updating job $jobid ($success) $message", $jobid);

  my $job =
  {
    'id' => $jobid,
    'success' =>  $success,
    'message' => $message,
    'stdout' => $stdout,
    'stderr' => $stderr,
    'returnvalue' => $returnvalue
  };
  my $xmljob = XMLout($job, rootname => "job");

  my $ua = LWP::UserAgent->new;

  my $response = $ua->request(POST SMTConfig::smtUrl().SMTConstants::REST_UPDATE_JOB.$jobid,
    'Content-Type' => 'text/xml',
     Content        => $xmljob
  );

  if (! $response->is_success )
  {
    # Do not pass the jobid to the error() because that 
    # causes an infinit recursion
    error( "Unable to update job: " . $response->status_line . "-" . $response->content );
  }
  else
  {
    SMTUtils::logger( "successfully updated job $jobid");
  }
};


###############################################################################
# retrieve the a job from the smt server
# args: jobid
# returns: job description in xml
sub getjob
{
  my ($id) = @_;


  my $ua = LWP::UserAgent->new;
  my $response = $ua->request(GET SMTConfig::smtUrl().SMTConstants::REST_GET_JOB.$id); 
  if (! $response->is_success )
  {
    error( "Unable to request job $id: " . $response->status_line . "-" . $response->content );
  }

  return $response->content;
};


###############################################################################
# retrieve the next job from the smt server
# args: none
# returns: job description in xml
sub getnextjob
{
  my $ua = LWP::UserAgent->new;
  my $response = $ua->request(GET SMTConfig::smtUrl().SMTConstants::REST_NEXT_JOB);

  if (! $response->is_success )
  {
    error( "Unable to request next job: " . $response->status_line . "-" . $response->content );
  }

  return $response->content;
};



###############################################################################
# parse xml job description
# args:    xml
# returns: hash (id, type, args)
sub parsejob
{
  my $xmldata = shift;

  error( "xml doesn't contain a job description" ) if ( length( $xmldata ) <= 0 );

  my $job;
  my $jobid;
  my $jobtype;
  my $jobargs;

  # parse xml
  eval { $job = XMLin( $xmldata,  forcearray=>1 ) };
  error ( "unable to parse xml: $@" )              if ( $@ );
  error ( "job description contains invalid xml" ) if ( ! ( isa ($job, 'HASH' )));

  # retrieve variables
  $jobid   = $job->{id}        if ( defined ( $job->{id} )      && ( $job->{id} =~ /^[0-9]+$/ ));
  $jobtype = $job->{jobtype}   if ( defined ( $job->{jobtype} ) && ( $job->{jobtype} =~ /^[0-9a-zA-Z.]+$/ ));
  $jobargs = $job->{arguments} if ( defined ( $job->{arguments} ));

  # check variables
  error ( "jobid unknown or invalid." )                if ( ! defined( $jobid   ));
  error ( "jobtype unknown or invalid.",      $jobid ) if ( ! defined( $jobtype ));
  error ( "jobarguments unknown or invalid.", $jobid ) if ( ! defined( $jobargs ));

  SMTUtils::logger ( "got jobid \"$jobid\" with jobtype \"$jobtype\"", $jobid);

  return ( id=>$jobid, type=>$jobtype, args=>$jobargs );
};

###############################################################################
# parse xml job description                                                    
# args:    xml                                                                 
# returns: id                                                                  
sub parsejobid                                                                   
{                                                                              
  my $xmldata = shift;                                                         

  error ( "xml doesn't contain a job description" ) if ( length( $xmldata ) <= 0 );

  my $job;
  my $jobid;

  # parse xml
  eval { $job = XMLin( $xmldata,  forcearray=>1 ) };
  error ( "unable to parse xml: $@" )              if ( $@ );
  error ( "job description contains invalid xml" ) if ( ! ( isa ($job, 'HASH' ) ) );

  # retrieve variables
  $jobid = $job->{id} if ( defined ( $job->{id} ) && ( $job->{id} =~ /^[0-9]+$/ ) );

  return $jobid;
};


1;

