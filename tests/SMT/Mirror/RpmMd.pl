#!/usr/bin/env perl
use File::Temp;

BEGIN {
    push @INC, "../www/perl-lib";
}

use SMT::Mirror::RpmMd;
use IO::Zlib;
use Test::Simple tests => 6;

my $url = 'http://download.opensuse.org/repositories/home:/jkupec/openSUSE_11.1/';
my $tempdir = File::Temp::tempdir(CLEANUP => 1);
print STDERR "Saving $url to $tempdir\n";

$mirror = SMT::Mirror::RpmMd->new();
$mirror->uri( $url );
$mirror->localBasePath("$tempdir");
$mirror->localRepoPath('');
$mirror->vblevel(0xffff);

ok($mirror->mirror() == 0, "should mirror ok");
ok($mirror->statistic()->{TOTALFILES} != $mirror->statistic()->{UPTODATE}, "first mirror() should download all the files");
ok($mirror->verify(), "mirrored data should pass checksum verifications");
ok($mirror->mirror() == 0, "second mirror should work");
ok($mirror->statistic()->{TOTALFILES} == $mirror->statistic()->{UPTODATE}, "second mirror() should not download anything");

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
ok( $mirror->verify() == 0, "should not verify after a file has been corrupted");
