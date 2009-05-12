#!/usr/bin/env perl
use strict;
use warnings;

sub jobhandler
{
  my %retval;
  my ($jobtype, $jobid, $args) =  @_;

  logger ("jobhandler for softwarepush called", $jobid);
  logger ("softwarepush runs jobid \"$jobid\"", $jobid);


  # check whether this handler can handle requested jobtype
  error ("wrong job handler: \"softwarepush\" cannot handle \"$jobtype\"", $jobid) if ( $jobtype ne "softwarepush" );


  # collect and verify arguments
  my $force;
  my $agreelicenses;
  my $packages;


  $force   = $args->[0]->{force}->[0]			if ( defined ( $args->[0]->{force}->[0] ) );
  error( "argument missing: force", $jobid )		if ( ! defined( $force ) );
  error( "argument invalid: force", $jobid )		if ( ! ( $force eq "true" || $force eq "false" ) );

  $agreelicenses = $args->[0]->{agreelicenses}->[0]	if ( defined ( $args->[0]->{agreelicenses}->[0] ) );
  error( "argument missing: agreelicenses", $jobid )	if ( ! defined( $agreelicenses ) );
  error( "argument invalid: agreelicenses", $jobid )	if ( ! ( $agreelicenses eq "true" || $agreelicenses eq "false" ) );


  $packages   = $args->[0]->{packages}->[0]->{package}	if ( defined ( $args->[0]->{packages}->[0]->{package}  ) );
  error( "argument missing: packages", $jobid ) 	if ( ! defined( $packages   ));
  error( "argument invalid: packages", $jobid )  	if ( ! isa($packages, 'ARRAY' ) );


  # assemble zypper commandline
  my $commandline = "/usr/bin/zypper ";
  $commandline .= " --non-cd ";					# ignore CD/DVD repositories
  $commandline .= " -x ";					# xml output
  $commandline .= " --non-interactive ";			# doesn't ask user
  $commandline .= " in ";					# install
  $commandline .= " -l " if ( $agreelicenses eq "true" );	# agree licenses
  $commandline .= " -f " if ( $force eq "true" );		# reinstall
  foreach my $pack (@$packages)
  {
    $commandline .= " $pack ";
  }


  logger ( "running zypper: $commandline", $jobid );

#  $command = "xterm";

#  my $pid = open3(\*IN, \*OUT, \*ERR, $command, @cmdArgs) or do {
#    logPrintError($ctx, "Cannot execute $command ".join(" ", @cmdArgs).": $!\n",13);
#    return;
#  };
#
#  my $out;
#  my $err;
#
#  while (<OUT>)
#  {
#    $out .= "$_";
#  }
#    
#  while (<ERR>)
#  {
#    $err .= "$_";
#  }
#
#  close OUT;
#  close ERR;
#  close IN;
#
#  waitpid $pid, 0;
#
#  $reval = ($?>>8);






  ## TODO run zypper
  %retval = (
    success => "true",
    message => "successfully installed packages"
  );

  return %retval;

}

logger ("successfully loaded handler for jobtype \"softwarepush\"");

return 1;

