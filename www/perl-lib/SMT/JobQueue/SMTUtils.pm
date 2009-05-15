#!/usr/bin/env perl
package SMTUtils;

use strict;
use warnings;
use SMTConstants;
use IO::File;


sub openLog
{
  my $LOG;
  sysopen($LOG, SMTConstants::LOG_FILE, O_CREAT|O_APPEND|O_WRONLY, 0600) or die "Cannot open logfile".SMTConstants::LOG_FILE.": $!";
  $LOG->autoflush(1);
  
  return $LOG;
}

my $LOG=openLog();

sub logger
{
  my ( $message, $jobid ) =  @_;

  return if ( ! defined $LOG );

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
  $year += 1900;
  $mon +=1;
  my $time = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year,$mon,$mday, $hour,$min,$sec);

  # prevent multiline log entries
  $message =~ s/\n/ /g;

  if ( defined ( $jobid ) )
  {
    print ($LOG "$time: ($jobid) $message\n") ;
  }
  else
  
  {
    print ($LOG "$time: () $message\n") ;
  }
}




1;
