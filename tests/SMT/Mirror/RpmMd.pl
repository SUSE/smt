#!/usr/bin/env perl
use File::Temp;

BEGIN {
    push @INC, "../../../www/perl-lib";
}

use SMT::Mirror::RpmMd;
use IO::Zlib;
use Test::Simple tests => 6;

my $url = 'http://download.opensuse.org/repositories/home:/dmacvicar/openSUSE_10.3/';
my $tempdir = File::Temp::tempdir(CLEANUP => 1);
print STDERR "Saving $url to $tempdir\n";

$mirror = SMT::Mirror::RpmMd->new();
$mirror->uri( $url );
# FIXME mirrorTo does not exist
ok($mirror->mirrorTo( $tempdir ) == 0, "should mirror ok");

# last should have been a full mirror
ok($mirror->lastUpToDate() == 0, "first mirror should be full");

# verify
ok($mirror->verify($tempdir), "mirror should verify");

# mirror again, we should be uptodate
ok($mirror->mirrorTo( $tempdir ) == 0, "second mirror should work");
ok($mirror->lastUpToDate() == 1, "second mirror should be fast");

# now lets corrupt the directory
$fh = new IO::Zlib("$tempdir/repodata/other.xml.gz", "ab9");
if(defined $fh)
{
    print $fh "     ";
    $fh->close();
}
else
{
    die "Cannot open file $tempdir/repodata/other.xml.gz: $!";
}

# now it should not verify
ok( $mirror->verify($tempdir) == 0, "should not verify after corrupted");



