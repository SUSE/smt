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
  my $packages;


  $force   = $args->[0]->{force}->[0]			if ( defined ( $args->[0]->{force}->[0] ) );
  error( "argument missing: force", $jobid )		if ( ! defined( $force ) );
  error( "argument invalid: force", $jobid )		if ( ! ( $force eq "true" || $force eq "false" ) );

  $packages   = $args->[0]->{packages}->[0]->{package}	if ( defined ( $args->[0]->{packages}->[0]->{package}  ) );
  error( "argument missing: packages", $jobid ) 	if ( ! defined( $packages   ));
  error( "argument invalid: packages", $jobid )  	if ( ! isa($packages, 'ARRAY' ) );


  # run business logics
  logger ( "softwarepush args: force = \"$force\"", $jobid );
  foreach my $pack (@$packages)
  {
    logger ( "softwarepush args: packagelist contains \"$pack\"", $jobid );
  }
  logger ( "end of softwarepush", $jobid );


  ## TODO run zypper
  %retval = (
    success => "true",
    message => "successfully installed packages"
  );

  return %retval;

}

logger ("successfully loaded handler for jobtype \"softwarepush\"");

return 1;

