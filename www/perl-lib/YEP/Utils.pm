package YEP::Utils;

use strict;
use warnings;

use Config::IniFiles;
use DBI;
use Fcntl;

use Locale::gettext ();
use POSIX ();     # Needed for setlocale()

POSIX::setlocale(&POSIX::LC_MESSAGES, "");

our @ISA = qw(Exporter);
our @EXPORT = qw(__);


#
# read db values from the yep configuration file,
# open the database and returns the database handle
#
sub db_connect
{
    my $cfg = new Config::IniFiles( -file => "/etc/yep.conf" );
    if(!defined $cfg)
    {
        # FIXME: is die correct here?
        die sprintf(__("Cannot read the YEP configuration file: %s"), @Config::IniFiles::errors);
    }
    
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
    my $domain = "yep";
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
        return 0;
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


1;
