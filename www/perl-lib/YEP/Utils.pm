package YEP::Utils;

use strict;
use warnings;

use Config::IniFiles;
use DBI;

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
        die __("Cannot read the YEP configuration file: ").@Config::IniFiles::errors;
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
sub __ {
    my $msgid = shift;
    my $package = caller;
    my $domain = "yep";
    return Locale::gettext::dgettext ($domain, $msgid);
}

1;
