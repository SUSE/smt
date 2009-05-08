#!/usr/bin/env perl
use strict;
use warnings;
use constant HOST => 'http://localhost/cgi-bin/smt.cgi';
use HTTP::Request;
use HTTP::Request::Common;
use LWP::UserAgent;
use XML::Simple;
use Data::Dumper;
use UNIVERSAL 'isa';


###############################################################################
# exit with error 
# args: message, jobid
sub error
{
  my ( $message, $jobid) =  @_;

  if ( defined ($jobid))
  {
    logger ("let's tell the server that $jobid failed");
    updatejob ( $jobid, "false", $message );
  }
  die "Error: $message\n";
};


###############################################################################
# write a log line 
# args: message, jobid
sub logger
{
  my ( $message, $jobid) =  @_;
  if (defined $jobid)
  {
    print ("Log: ($jobid) $message\n");
  }
  else
  {
    print ("Log: () $message\n");
  }
};


###############################################################################
# updates status of a job on the smt server
# args: jobid, success, message 
sub updatejob
{
  my ($jobid, $success, $message) =  @_;

  logger( "updating job $jobid ($success) $message", $jobid);

  my $job =
  {
    'id' => $jobid,
    'success' =>  $success,
    'message' => $message
  };
  my $xmljob = XMLout($job, rootname => "job");

  my $ua = LWP::UserAgent->new;

  my $response = $ua->request(POST HOST."/=v1=/smt/job/id/$jobid",
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
    logger( "successfully updated job $jobid");
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
  my $response = $ua->request(GET HOST."/=v1=/smt/job/id/$id");

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
  error( "unable to parse xml: $@" )              if ( $@ );
  error( "job description contains invalid xml" ) if ( ! ( isa ($job, 'HASH' )));

  # retrieve variables
  $jobid   = $job->{id}        if ( defined ( $job->{id} )      && ( $job->{id} =~ /^[0-9]+$/ ));
  $jobtype = $job->{jobtype}   if ( defined ( $job->{jobtype} ) && ( $job->{jobtype} =~ /^[a-z]+$/ ));
  $jobargs = $job->{arguments} if ( defined ( $job->{arguments} ));

  # check variables
  error( "jobid unknown or invalid." )                if ( ! defined( $jobid   ));
  error( "jobtype unknown or invalid.",      $jobid ) if ( ! defined( $jobtype ));
  error( "jobarguments unknown or invalid.", $jobid ) if ( ! defined( $jobargs ));

  logger( "got jobid \"$jobid\" with jobtype \"$jobtype\"", $jobid);

  return ( id=>$jobid, type=>$jobtype, args=>$jobargs );
};


###############################################################################
# load job handler
# args: jobtype, jobid
sub loadjobhandler
{
  my ( $jobtype, $jobid) =  @_;

  eval { require "$jobtype.pl" };
  error( "unable to load handler for jobtype \"$jobtype\": $@", $jobid ) if ( $@ );
}


###############################################################################
sub main
{
  my  $jobid  =  $ARGV[0];
  print "jobid: $jobid";

  my $xmldata = getjob( $jobid );
  my %jobdata = parsejob( $xmldata );

  loadjobhandler ( $jobdata{type}, $jobdata{id} ); 

  my %retval = jobhandler ( $jobdata{type}, $jobdata{id}, $jobdata{args} );

  updatejob ( $jobdata{id}, $retval{success}, $retval{message}  );
}

main( );







