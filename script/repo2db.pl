#!/usr/bin/perl

#
# Maybe this is not needed anymore. I implemented
# filling the database in the mirror script.
#



use strict;
use warnings;
use SMT::Mirror::NU;
use SMT::Mirror::RpmMd;
use SMT::Utils;
use Config::IniFiles;
use URI;
use Getopt::Long;
use File::Basename;

use Locale::gettext ();
use POSIX ();     # Needed for setlocale()

POSIX::setlocale(&POSIX::LC_MESSAGES, "");


use Data::Dumper;

my $debug   = 0;
my $help    = 0;
my $logfile = "/dev/null";

my $result = GetOptions ("debug|d"     => \$debug,
                         "logfile|L=s" => \$logfile,
                         "help|h"      => \$help
                        );

if($help)
{
    print basename($0) . " [--debug] [--logfile file]\n\n";
    print __("Write repository data into the database\n");
    print "\n";
    print __("Options:\n");
    print "--debug -d        ".__("enable debug mode\n");
    print "--logfile -L file ".__("Path to logfile\n");
    exit 0;
}




# get a lock

if(!SMT::Utils::openLock("repo2db"))
{
    print __("Process is still running.\n");
    exit 0;
}

# open the logfile

my $LOG = SMT::Utils::openLog($logfile);

my $cfg = undef;

eval
{
    $cfg = SMT::Utils::getSMTConfig();
};
if($@ || !defined $cfg)
{
    if(!SMT::Utils::unLock("repo2db"))
    {
        SMT::Utils::printLog($LOG, "error",  __("Cannot remove lockfile."));
    }
    SMT::Utils::printLog($LOG, "error", sprintf(__("Cannot read the SMT configuration file: %s"), $@));
    exit 1;
}

my $LocalBasePath = $cfg->val("LOCAL", "MirrorTo");
if(!defined $LocalBasePath || $LocalBasePath eq "" || !-d $LocalBasePath)
{
    if(!SMT::Utils::unLock("repo2db"))
    {
        SMT::Utils::printLog($LOG, "error", __("Cannot remove lockfile."));
    }
    SMT::Utils::printLog($LOG, "error", __("Cannot read the local base path"));
    exit 1;
}


my $dbh = undef;

$dbh = SMT::Utils::db_connect();

if(!$dbh)
{
    if(!SMT::Utils::unLock("repo2db"))
    {
        SMT::Utils::printLog($LOG, "error", __("Cannot remove lockfile."));
    }
    SMT::Utils::printLog($LOG, "error", __("Cannot connect to database"));
    exit 1;
}

$dbh->do("DELETE from RepositoryContentData");

my $hash = $dbh->selectall_hashref( "select CATALOGID, LOCALPATH from Catalogs where MIRRORABLE='Y' and DOMIRROR='Y'", "CATALOGID" );

foreach my $id (keys %{$hash})
{
    my $localdir = SMT::Utils::cleanPath("$LocalBasePath/repo/".$hash->{$id}->{LOCALPATH});
    
    my $path = "$localdir/repodata/repomd.xml";
    
    next if( ! -e $path );
    
    $localdir =~ s/\/$//;

    SMT::Utils::printLog($LOG, "debug", "Parse '$localdir'")  if($debug);

    my $self = {};
    $self->{DBH} = $dbh;
    $self->{LOG} = $LOG;
    $self->{DEBUG} = $debug;
    $self->{LOCALDIR} = $localdir;
    
    my $parser = SMT::Parser::RpmMd->new(log => $LOG);
    $parser->resource($localdir);
    $parser->parse("repodata/repomd.xml", sub { toDB_handler($self, @_)});
}

sub toDB_handler
{
    my $self = shift;
    my $data = shift;

    #printLog($self->{LOG}, "debug", Data::Dumper->Dump([$data]) ) if($self->{DEBUG});

    if(exists $data->{LOCATION} && defined $data->{LOCATION} &&
       $data->{LOCATION} ne "" )
    {
        my $fullpath = SMT::Utils::cleanPath($self->{LOCALDIR}."/".$data->{LOCATION});
        my $packagename = basename($fullpath);
        
        my $statement = "";
        $statement = sprintf("SELECT localpath from RepositoryContentData where localpath = %s", $self->{DBH}->quote($fullpath));

        printLog($self->{LOG}, "debug", "$statement") if($self->{DEBUG});
        my $existingpath = $dbh->selectcol_arrayref($statement);

        if(exists $existingpath->[0])
        {
            $statement = sprintf("UPDATE RepositoryContentData set name=%s, checksum=%s where localpath=%s",
                                 $self->{DBH}->quote($packagename),
                                 $self->{DBH}->quote($data->{CHECKSUM}),
                                 $self->{DBH}->quote($fullpath)
                                );
        }
        else
        {
            $statement = sprintf("INSERT INTO RepositoryContentData (name, checksum, localpath) VALUES (%s, %s, %s)",
                                 $self->{DBH}->quote($packagename),
                                 $self->{DBH}->quote($data->{CHECKSUM}),
                                 $self->{DBH}->quote($fullpath)
                                );
        }
        
        $self->{DBH}->do($statement);
        printLog($self->{LOG}, "debug", "$statement") if($self->{DEBUG});
    }
    
}
