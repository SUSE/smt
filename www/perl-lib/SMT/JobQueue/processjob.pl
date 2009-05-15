#!/usr/bin/env perl
use strict;
use warnings;
use SMTConstants;
use SMTConfig;
use SMTUtils;
use SMTRestXML;
use UNIVERSAL 'isa';


###############################################################################
# load job handler
# args: jobtype, jobid
sub loadjobhandler
{
  my ( $jobtype, $jobid) =  @_;

  # prevent command injection
  SMTUtils::error ( "cannot load non-alphanumeric jobs." ) unless ( $jobtype =~ /^[0-9A-Za-z]+$/ );

  my $jobhandler = SMTConstants::JOB_HANDLER_PATH."/".$jobtype.".pl";

  eval { require $jobhandler };
  SMTUtils::error( "unable to load handler for jobtype \"$jobtype\": $@", $jobid ) if ( $@ );
}





my  $jobid  =  $ARGV[0];
SMTUtils::logger ( "jobid: $jobid" );

my $xmldata = SMTRestXML::getjob( $jobid );
my %jobdata = SMTRestXML::parsejob( $xmldata );

loadjobhandler ( $jobdata{type}, $jobdata{id} ); 

my %retval = jobhandler ( $jobdata{type}, $jobdata{id}, $jobdata{args} );

SMTUtils::logger ( "job ". $jobdata{id}. (( $retval{success} eq "true")?" successfully finished":" FAILED"), $jobdata{id} );
SMTUtils::logger ( "job ". $jobdata{id}. " message: ".$retval{message}, $jobdata{id} );
SMTUtils::logger ( "job ". $jobdata{id}. " stdout: ".$retval{stdout}, $jobdata{id} );
SMTUtils::logger ( "job ". $jobdata{id}. " stderr: ".$retval{stderr}, $jobdata{id} );
SMTUtils::logger ( "job ". $jobdata{id}. " returnvalue: ".$retval{returnvalue}, $jobdata{id} );

SMTRestXML::updatejob ( $jobdata{id}, $retval{success}, $retval{message}, $retval{stdout}, $retval{stderr}, $retval{returnvalue} );




