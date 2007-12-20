#!/usr/bin/env perl

BEGIN {
    push @INC, "/space/git/suse/yep/www/perl-lib";
}

use YEP::Mirror::Job;
use Test::Simple tests => 1;

#my $url = 'https://MIRRORUSER:MIRRIRPASSWORD@nu.novell.com/repo/repoindex.xml';

$job = YEP::Mirror::Job->new();
$job->uri( "http://download.opensuse.org/repositories/home:/dmacvicar/openSUSE_10.3/repodata/repomd.xml" );
print $job->modified();
ok(1);
