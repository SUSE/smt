#!/usr/bin/env perl
use strict;
use warnings;
use constant HOST => 'http://localhost/cgi-bin/smt.cgi';
use constant PROCESSJOB => '/home/store/yep/trunk/www/perl-lib/SMT/JobQueue/processjob.pl';
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
  my ( $message, $jobid ) =  @_;

  if ( defined ( $jobid ) )
  {
    logger ( "let's tell the server that $jobid failed" );
    updatejob ( $jobid, "false", $message );
  }
  die "Error: $message\n";
};


###############################################################################
# write a log line 
# args: message, jobid
sub logger
{
  my ( $message, $jobid ) =  @_;
  if ( defined ( $jobid ) )
  {
    print ( "Log: ($jobid) $message\n" );
  }
  else
  {
    print ( "Log: () $message\n" );
  }
};



###############################################################################
# retrieve the next job from the smt server
# args: none
# returns: job description in xml
sub getnextjob
{
  my $ua = LWP::UserAgent->new;
  my $response = $ua->request(GET HOST."/=v1=/smt/job/id/next");

  if (! $response->is_success )
  {
    error( "Unable to request next job: " . $response->status_line . "-" . $response->content );
  }

  return $response->content;
};

###############################################################################
# parse xml job description
# args:    xml
# returns: id
sub parsejob
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


###############################################################################
sub main
{
  my $jobid;

  while( defined ( $jobid = parsejob( getnextjob() )))
  {
      # prevent command injection
      error ( "cannot run jobs with non-numeric jobid." ) unless ( $jobid =~ /^[0-9]+$/ );
      my $command = PROCESSJOB." ".$jobid;

      print "running $jobid...\n";
      print `$command`;
      sleep (3);
  }
}

main();







