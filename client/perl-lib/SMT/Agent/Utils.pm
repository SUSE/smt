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

  my $jobidstr = (defined $jobid) ? $jobid : '';
  print ($LOG "$time: ($jobidstr) $message\n") ;
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

    return ($code, $out, $err);
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
    SMT::Agent::RestXML::updatejob ( $jobid, 2, $message );
  }
  SMT::Agent::Utils::logger ("ERROR: $message", $jobid);
  die "Error: $message\n";
};


sub isAgentAllowed
{
  my $agent = shift;
  return 0 unless defined $agent;
  my $allowedagents = SMT::Agent::Config::getSysconfigValue( "ALLOWED_AGENTS" );
  return 0 unless (defined $allowedagents);
  $allowedagents =~ s/\s+/ /g;
  my %hash = map {$_ => 1} (split (" ", $allowedagents));
  return exists $hash{$agent};
}

sub isAllowedToCreate
{
  my $jobtype = shift;
  my $allowedcreate = SMT::Agent::Config::getSysconfigValue( "ALLOWED_CREATEJOB_JOBS" );
  return 0 unless (defined $allowedcreate);
  $allowedcreate =~ s/\s+/ /g;
  my %hash = map {$_ => 1} (split (" ", $allowedcreate));
  return exists $hash{$jobtype};
}


# check whether smt url is denied
sub isServerDenied
{
  my $server =  shift || SMT::Agent::Config::smtUrl();
  $server =~ s/.*:\/\///;	#remove protocol part from url 

  my $denied = SMT::Agent::Config::getSysconfigValue( "DENIED_SMT_SERVERS" );
  return 0 unless defined $denied;

  my @deniedlist = split(/ /, $denied);

  foreach my $item ( @deniedlist )
  {
    return 1 if ( substr($item,0,1) ne "." &&  $server =~ /^$item$/ );	# host match
    return 1 if ( substr($item,0,1) eq "." && $server =~/.*$item$/ ); 	# domain match
  }

  return 0;
}


#
# lock file support
#

=item openLock($progname)

Try to create a lock file in /run/smtclient/$progname.pid .
Return TRUE on success, otherwise FALSE.

=cut
sub openLock
{
    my $progname = shift;
    my $pid = $$;
    
    my $dir  = "/run/smtclient";
    mkdir $dir;
    my $path = "$dir/$progname.pid";
    
    return 0 if( !-d $dir || !-w $dir );

    if( -e $path )
    {
        # check if the process is still running

        my $oldpid = "";
        
        open(LOCK, "< $path") and do {
            $oldpid = <LOCK>;
            close LOCK;
        };
        
        chomp($oldpid);
        
        if( ! -e "/proc/$oldpid/cmdline")
        {
            # pid does not exists; remove lock
            unlink $path;
        }
        else
        {
            my $cmdline = "";
            open(CMDLINE, "< /proc/$oldpid/cmdline") and do {
                $cmdline = <CMDLINE>;
                close CMDLINE;
            };
            
            if($cmdline !~ /$progname/)
            {
                # this pid is a different process; remove the lock
                unlink $path;
            }
            else
            {
                # process still running
                return 0;
            }
        }
    }
    
    sysopen(LOCK, $path, O_WRONLY | O_EXCL | O_CREAT, 0640) or return 0;
    print LOCK "$pid";
    close LOCK;

    return 1;
}

=item unLock($progname)

Try to remove the lockfile
Return TRUE on success, otherwise false

=cut
sub unLock
{
    my $progname = shift;
    my $pid = $$;
    
    my $dir = "/run/smtclient";
    mkdir $dir;
    my $path = "$dir/$progname.pid";
    
    if(! -e $path )
    {
        return 1;
    }
    
    open(LOCK, "< $path") or return 0;
    my $dp = <LOCK>;
    close LOCK;
    
    if($dp ne "$pid")
    {
        return 0;
    }
    
    my $cnt = unlink($path);
    return 1 if($cnt == 1);
    
    return 0;
}

1;


