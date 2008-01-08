#!/usr/bin/env perl
use File::Temp;

BEGIN {
    push @INC, "/space/git/suse/yep/www/perl-lib";
}

use YEP::Mirror::RpmMd;
use Test::Simple tests => 1;

my $url = 'http://download.opensuse.org/repositories/home:/dmacvicar/openSUSE_10.3/';
my $tempdir = File::Temp::tempdir();
print STDERR "Saving $url to $tempdir\n";

$mirror = YEP::Mirror::RpmMd->new();
$mirror->uri( $url );
ok($mirror->mirrorTo( $tempdir ) == 0);

ok($mirror->verify($tempdir) == 0);