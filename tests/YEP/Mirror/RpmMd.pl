#!/usr/bin/env perl

BEGIN {
    push @INC, "/space/git/suse/yep/www/perl-lib";
}

use YEP::Mirror::RpmMd;
use Test::Simple tests => 1;

#my $url = 'https://MIRRORUSER:MIRRIRPASSWORD@nu.novell.com/repo/repoindex.xml';

$mirror = RpmMd->new();
$mirror->url( "http://download.opensuse.org/repositories/home:/dmacvicar/openSUSE_10.3/ " );
$mirror->mirrorTo( "/space/git/suse/yep/www" );

ok(1);
