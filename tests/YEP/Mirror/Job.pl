#!/usr/bin/env perl

use YEP::Mirror::Job;
use Test::Simple tests => 2;

#my $url = 'https://MIRRORUSER:MIRRIRPASSWORD@nu.novell.com/repo/repoindex.xml';

$job = YEP::Mirror::Job->new();
$job->uri( "http://download.opensuse.org/repositories/home:/dmacvicar/openSUSE_10.3" );
$job->resource( "/repodata/repomd.xml" );
$job->localdir( "./testdata/jobtest/" );
ok($job->modified() > 0);
ok($job->outdated());
