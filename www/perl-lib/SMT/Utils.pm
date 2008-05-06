package SMT::Utils;

use strict;
use warnings;

use Config::IniFiles;
use DBI qw(:sql_types);
use Fcntl qw(:DEFAULT);
use IO::File;

use MIME::Lite;  # sending eMails
use Net::SMTP;   # sending eMails via smtp relay

use Locale::gettext ();
use POSIX ();     # Needed for setlocale()

POSIX::setlocale(&POSIX::LC_MESSAGES, "");

our @ISA = qw(Exporter);
our @EXPORT = qw(__ printLog);


#
# read SMT config file and return a hash
#        will result in a "die" on error
#
sub getSMTConfig
{
    my $filename = shift || "/etc/smt.conf";
    
    my $cfg = new Config::IniFiles( -file => $filename );
    if(!defined $cfg)
    {
        # FIXME: is die correct here?
        die sprintf(__("Cannot read the SMT configuration file: %s"), @Config::IniFiles::errors);
    }

    return $cfg;
}



#
# read db values from the smt configuration file,
# open the database and returns the database handle
#
sub db_connect
{
    my $cfg = getSMTConfig;

    my $config = $cfg->val('DB', 'config');
    my $user   = $cfg->val('DB', 'user');
    my $pass   = $cfg->val('DB', 'pass');
    if(!defined $config || $config eq "")
    {
        # FIXME: is die correct here?
        die __("Invalid Database configuration. Missing value for DB/config.");
    }

    my $dbh    = DBI->connect($config, $user, $pass, {RaiseError => 1, AutoCommit => 1});

    return $dbh;
}

#
# localization function
#
sub __ 
{
    my $msgid = shift;
    my $package = caller;
    my $domain = "smt";
    return Locale::gettext::dgettext ($domain, $msgid);
}

#
# lock file support
#

#
# try to create a lock file in /var/run/
# Return TRUE on success, otherwise FALSE
#
sub openLock
{
    my $progname = shift;
    my $pid = $$;
    
    my $path = "/var/run/$progname.pid";
    
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

#
# try to remove the lockfile
# Return TRUE on success, otherwise false
#
sub unLock
{
    my $progname = shift;
    my $pid = $$;
    
    my $path = "/var/run/$progname.pid";
    
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

#
# Return an array with ($url, $guid, $secret)
#
sub getLocalRegInfos
{
    my $uri    = "";

    open(FH, "< /etc/suseRegister.conf") or die sprintf(__("Cannot open /etc/suseRegister.conf: %s"), $!);
    while(<FH>)
    {
        if($_ =~ /^url\s*=\s*(\S*)\s*/ && defined $1 && $1 ne "")
        {
            $uri = $1;
            last;
        }
    }
    close FH;

    if(!defined $uri || $uri eq "")
    {
        die __("Cannot read URL from /etc/suseRegister.conf");
    }

    my $cfg = getSMTConfig;

    my $user   = $cfg->val('NU', 'NUUser');
    my $pass   = $cfg->val('NU', 'NUPass');
    if(!defined $user || $user eq "" || 
       !defined $pass || $pass eq "")
    {
        # FIXME: is die correct here?
        die __("Cannot read Mirror Credentials from SMT configuration file.");
    }

    return ($uri, $user, $pass);  
}

#
# Return deviceid (guid) of the SMT server
#
sub getSMTGuid
{
    my $guid   = "";
    open(FH, "< /etc/zmd/deviceid") or die sprintf(__("Cannot open /etc/zmd/deviceid: %s"), $!);
    
    $guid = <FH>;
    chomp($guid);
    close FH;
    
    return $guid;
}


#
# You can provide a parameter in seconds from 1970-01-01 00:00:00
# If you do not provide a parameter the current time is used.
#
# return the timestamp in database format
# YYY-MM-DD hh:mm:ss
#
sub getDBTimestamp
{
    my $time = shift || time;
    
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
    $year += 1900;
    $mon +=1;
    my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year,$mon,$mday, $hour,$min,$sec);
    return $timestamp;
}


#
# open logfile
#
sub openLog
{
    my $logfile = shift || "/dev/null";
    
    my $LOG;
    sysopen($LOG, "$logfile", O_CREAT|O_APPEND|O_WRONLY, 0600) or die "Cannot open logfile '$logfile': $!";
    if($logfile ne "/dev/null")
    {
        $LOG->autoflush(1);
    }
    return $LOG;
}

sub printLog
{
    my $LOG      = shift;
    my $category = shift;
    my $message  = shift;
    my $doprint  = shift;
    my $dolog    = shift;
    if (! defined $doprint) { $doprint = 1;}
    if (! defined $dolog)   { $dolog   = 1;}

    if($doprint)
    {
        if(lc($category) eq "error")
        {
            print STDERR "$message\n";
        }
        else
        {
            print "$message\n";
        }
    }
    
    if($dolog && defined $LOG)
    {
        my ($package, $filename, $line) = caller;
        foreach (split(/\n/, $message))
        {
            print $LOG getDBTimestamp()." $package - [$category]  $_\n";
        }
    }
    return;
}


#
# sends an eMail with the passed content to the administrators defined in smt.conf as "reportEmail"
#                                   this function will do nothing if no eMail address is specified
#
sub sendMailToAdmins
{
    my $message = shift;
    my $attachments = shift;
    if (! defined $message)  { return; }
    
    my $cfg = getSMTConfig;

    my $getReportEmail = $cfg->val('REPORT', 'reportEmail');
    my @reportEmailList = split(/,/, $getReportEmail);
    my @addressList = ();
    foreach my $val (@reportEmailList)
    {
        $val =~ s/^\s*//;
        $val =~ s/\s*$//;

        push @addressList, $val;
    }
    if (scalar(@addressList) < 1 )  { return; }
    my $reportEmailTo = join(', ', @addressList);

    # read config for smtp relay
    my %relay = ();
    $relay{'server'}    = $cfg->val('REPORT', 'mailServer');
    $relay{'port'}      = $cfg->val('REPORT', 'mailServerPort');
    $relay{'user'}      = $cfg->val('REPORT', 'mailServerUser');
    $relay{'password'}  = $cfg->val('REPORT', 'mailServerPassword');
    my $reportEmailFrom = $cfg->val('REPORT', 'reportEmailFrom');

    if (! defined $reportEmailFrom  || $reportEmailFrom eq '')
    { $reportEmailFrom = "$ENV{'USER'}\@".`/bin/hostname --fqdn`; }

    my $datestring = POSIX::strftime("%Y-%m-%d %H:%M", localtime);

    # create the mail config
    my $mtype = 'sendmail';   # default to send eMail directly

    if (defined $relay{'server'}  &&  $relay{'server'} ne '')
    {
        # switch to smtp if a relay is defined
        $mtype = 'smtp';

        # make sure the port is valid
        if (! defined $relay{'port'} || $relay{'port'} !~ /^\d+$/ )
        {
            $relay{'port'} = '';
        }

        $relay{'Relay'} = "$relay{'server'}";
        if ($relay{'port'} ne '')
        {
            $relay{'Relay'} .= ":$relay{'port'}";
        }

        if (defined $relay{'user'}  &&  $relay{'user'} ne '')
        {
            # make sure we have a password - even if empty
            if (! defined $relay{'password'} )
            {
                $relay{'password'} = '';
            }
        }
        else 
        {
            # if no authentication is needed - set user to undef
            $relay{'user'} = undef;
        }

    }

    # create the message
    my $msg = MIME::Lite->new( 'From'    => $reportEmailFrom,
                               'To'      => $reportEmailTo,
                               'Subject' => "SMT Report $datestring",
                               'Type'    => 'multipart/mixed'
                             );

    # attach message as mail body
    $msg->attach( 'Type' => 'TEXT',
                  'Data' => $message
                );


    if (defined $attachments  &&  scalar(keys %{$attachments} ) > 0 )
    {
        foreach my $filename ( sort keys %{$attachments})
        {
            $msg->attach( 'Type'        =>'text/csv',
                          'Filename'    => $filename,
                          'Data'        => ${$attachments}{$filename},
                          'Disposition' => 'attachment'
                 );
        }
    }

    if ($mtype  eq  'sendmail')
    {
        # send message via sendmail (-t automatically scans for the recipients in the header)
        $msg->send($mtype, "/usr/lib/sendmail -t -oi ");
    }
    else
    {
        # send message via NET::SMTP
        if (defined $relay{'user'})
        {
            # with user authentication
            $msg->send('smtp', $relay{'Relay'}, 'AuthUser' => $relay{'user'}, 'AuthPass' => $relay{'password'}  );
        }
        else
        {
            # or withour user authentication
            $msg->send($mtype, $relay{'Relay'});
        }
    }

    return;
}


1;
