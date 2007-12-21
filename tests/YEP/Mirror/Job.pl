#!/usr/bin/env perl

use YEP::Mirror::Job;
use Test::Simple tests => 1;

#my $url = 'https://MIRRORUSER:MIRRIRPASSWORD@nu.novell.com/repo/repoindex.xml';

$job = YEP::Mirror::Job->new();
$job->uri( "http://download.opensuse.org/repositories/home:/dmacvicar/openSUSE_10.3" );
$job->resource( "/repodata/repomd.xml" );
print $job->modified(),"\n";

print $job->outdated(),"\n";

ok(1);
