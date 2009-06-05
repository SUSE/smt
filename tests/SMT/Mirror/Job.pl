#!/usr/bin/env perl

use File::Temp;
use Test::Simple tests => 2;

use SMT::Mirror::Job;

my $tempdir = File::Temp::tempdir(CLEANUP => 1);

$job = SMT::Mirror::Job->new();
# FIXME need some solid URI, ideally an ad hoc local http server
$job->uri( 'http://download.opensuse.org/repositories/home:/jkupec/openSUSE_11.1/' );
$job->localBasePath( "$tempdir" );
$job->localRepoPath( '' );
$job->localFileLocation( 'repodata/repomd.xml' );

#$job->resource( "/repodata/repomd.xml" );
#$job->localdir( "./testdata/jobtest/" );

ok($job->modified() > 0);
ok($job->outdated());
