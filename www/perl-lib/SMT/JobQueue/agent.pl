#!/usr/bin/env perl
use strict;
use warnings;
use SMTConstants;
use SMTConfig;
use SMTUtils;
use SMTRestXML;


my $jobid;

while( defined ( $jobid = SMTRestXML::parsejobid( SMTRestXML::getnextjob() )))
{
  # prevent command injection
  SMTUtils::error ( "cannot run jobs with non-numeric jobid." ) unless ( $jobid =~ /^[0-9]+$/ );
  SMTUtils::logger ("running job $jobid", $jobid);
  SMTUtils::executeCommand ( SMTConstants::PROCESSJOB, undef, ( $jobid ) );
  #TODO: check whther executeCommand failed

  sleep (3);
}



