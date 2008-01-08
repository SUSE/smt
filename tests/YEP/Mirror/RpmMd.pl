#!/usr/bin/env perl
use File::Temp;

BEGIN {
    push @INC, "/space/git/suse/yep/www/perl-lib";
}

use YEP::Mirror::RpmMd;
use Test::Simple tests => 2;

my $url = 'http://download.opensuse.org/repositories/home:/dmacvicar/openSUSE_10.3/';
my $tempdir = File::Temp::tempdir(CLEANUP => 1);
print STDERR "Saving $url to $tempdir\n";

$mirror = YEP::Mirror::RpmMd->new();
$mirror->uri( $url );
ok($mirror->mirrorTo( $tempdir ) == 0);

# verify
ok($mirror->verify($tempdir) == 0);

# now lets corrupt the directory
open (FILEH, ">$tempdir/repodata/other.xml.gz") or die $!;
print FILEH "fooo";
close FILEH;

# now it should not verify
ok( $mirror->verify($tempdir) > 0 );
