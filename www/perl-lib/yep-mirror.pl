#!/usr/bin/env perl

###########################################################################
## Copyright (c) 2007 SUSE LINUX Products GmbH, Nuernberg, Germany.
###########################################################################

use YEP::Mirror::NU;
use YEP::Mirror::RpmMd;
use YEP::Utils;
use Config::IniFiles;
use File::Path;
use URI;
use Getopt::Long;

#use Data::Dumper;

my $debug = 0;
my $help  = 0;

my $result = GetOptions ("debug|d"     => \$debug,
                         "help|h"      => \$help
                        );


if($help)
{
    print "yep-mirror.pl [OPTIONS]\n";
    print "\n";
    print "Options:\n";
    print "--debug -d     enable debug mode\n";
    print "--help -h      show this message\n";
    exit 0;
}


my $dbh = YEP::Utils::db_connect();

if(!$dbh)
{
    die "Cannot connect to database";
}

my $cfg = new Config::IniFiles( -file => "/etc/yep.conf" );
if(!defined $cfg)
{
    die "Cannot read the YEP configuration file: ".@Config::IniFiles::errors;
}

my $NUUrl = $cfg->val("NU", "NUUrl");
if(!defined $NUUrl || $NUUrl eq "")
{
    die "Cannot read NU Url";
}

my $LocalBasePath = $cfg->val("NU", "LocalBasePath");
if(!defined $LocalBasePath || $LocalBasePath eq "")
{
    die "Cannot read the local base path";
}

my $nuUser = $cfg->val("NU", "NUUser");
my $nuPass = $cfg->val("NU", "NUPass");

if(!defined $nuUser || $nuUser eq "" ||
   !defined $nuPass || $nuPass eq "")
{
    die "Cannot read the Mirror Credentials";
}

my $uri = URI->new($NUUrl);
$uri->userinfo("$nuUser:$nuPass");

#
# search for all YUM repositories we need to mirror and start the mirror process
#
my $hash = $dbh->selectall_hashref( "select CatalogID, LocalPath, ExtUrl from Catalogs where CatalogType='yum' and DoMirror='Y'", "CatalogID" );

#print Data::Dumper->Dump([$hash]);

foreach my $id (keys %{$hash})
{
    if( $hash->{$id}->{ExtUrl} ne "" && $hash->{$id}->{LocalPath} ne "" )
    {
        my $fullpath = $LocalBasePath."/".$hash->{$id}->{LocalPath};
        &File::Path::mkpath( $fullpath );

        my $yumMirror = YEP::Mirror::RpmMd->new(debug => $debug);
        $yumMirror->uri( $hash->{$id}->{ExtUrl} );
        $yumMirror->mirrorTo( $fullpath, { urltree => 0 } );
    }
}

#
# Now mirror the NU catalogs
#
my $mirror = YEP::Mirror::NU->new(debug => $debug);
$mirror->uri( $uri->as_string );
$mirror->mirrorTo( $LocalBasePath, { urltree => 0 } );

