#!/usr/bin/env perl
use File::Temp;

BEGIN {
    push @INC, "../../../www/perl-lib";
}

use YEP::Mirror::RpmMd;
use IO::Zlib;
use Test::Simple tests => 3;

my $url = 'http://download.opensuse.org/repositories/home:/dmacvicar/openSUSE_10.3/';
my $tempdir = File::Temp::tempdir(CLEANUP => 1);
print STDERR "Saving $url to $tempdir\n";

$mirror = YEP::Mirror::RpmMd->new();
$mirror->uri( $url );
ok($mirror->mirrorTo( $tempdir ) == 0);

# verify
ok($mirror->verify($tempdir) == 0);

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
ok( $mirror->verify($tempdir) > 0 );
