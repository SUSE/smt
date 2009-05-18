#!/usr/bin/env perl
package SMT::Agent::Utils;

use strict;
use warnings;
use SMT::Agent::Constants;
use IO::File;
use IPC::Open3;



sub openLog
{
  my $LOG;
  sysopen($LOG, SMT::Agent::Constants::LOG_FILE, O_CREAT|O_APPEND|O_WRONLY, 0600) or die "Cannot open logfile".SMT::Agent::Constants::LOG_FILE.": $!";
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


sub executeCommand
{
    my $command = shift;
    my $input = shift;
    my @arguments = @_;
    
    my $out = "";
    my $err = "";
    my $code = 0;
    
    my $lang     = $ENV{LANG};
    my $language = $ENV{LANGUAGE};
    

    if(!defined $command || !-x $command)
    {
	SMT::Agent::Utils::logger("invalid Command '$command'");
        return undef;
    }

    # set lang to en_US to get output in english.
    $ENV{LANG}     = "en_US";
    $ENV{LANGUAGE} = "en_US";

    my $pid = open3(\*IN, \*OUT, \*ERR, $command, @arguments) or do {
        $ENV{LANG}     = $lang;
        $ENV{LANGUAGE} = $language;
	SMT::Agent::Utils::logger("Cannot execute $command ".join(" ", @arguments).": $!\n");
        return undef;
    };
    if(defined $input)
    {
        print IN $input;
    }
    close IN;
    
    while (<OUT>)
    {
        $out .= "$_";
    }
    while (<ERR>)
    {
        $err .= "$_";
    }
    close OUT;
    close ERR;
    
    waitpid $pid, 0;
    
    chomp($out);
    chomp($err);
    
    $ENV{LANG}     = $lang;
    $ENV{LANGUAGE} = $language;

    $code = ($?>>8);

    return ($code, $err, $out);
}


###############################################################################
# exit with error
# args: message, jobid
sub error
{
  my ( $message, $jobid ) =  @_;

  if ( defined ( $jobid ) )
  {
    SMT::Agent::Utils::logger ( "let's tell the server that $jobid failed" );
    SMT::Agent::RestXML::updatejob ( $jobid, "false", $message );
  }
  SMT::Agent::Utils::logger ("ERROR: $message", $jobid);
  die "Error: $message\n";
};


1;
