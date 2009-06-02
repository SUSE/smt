#!/usr/bin/env perl

BEGIN {
    push @INC, "../www/perl-lib";
}

use Test::Simple tests => 3;
use Cwd;
use File::Temp;

use SMT::Mirror::RpmMd;
use SMT::Filter;
use SMT::Parser::RpmMdPatches;
use SMT::Utils;

my $wd = Cwd::cwd();       # current working dir

#my $log = SMT::Utils::openLog('smt.log');
my $vblevel = LOG_DEBUG|LOG_DEBUG2|LOG_WARN|LOG_ERROR|LOG_INFO1|LOG_INFO2;

my $filter = SMT::Filter->new();
$filter->add(SMT::Filter->TYPE_NAME_VERSION, 'imap-368');
$filter->add(SMT::Filter->TYPE_NAME_VERSION, 'perl-DBD-mysql-543');

my $url = 'file://' . $wd . '/testdata/rpmmdtest/code11repo';  # FIXME this should use the testdir
my $tempdir = File::Temp::tempdir(CLEANUP => 1);
print STDERR "Mirroring $url to $tempdir\n";

$mirror = SMT::Mirror::RpmMd->new(filter => $filter, vblevel => $vblevel);
$mirror->uri($url);
$mirror->localBasePath("$tempdir");
$mirror->localRepoPath('');

ok($mirror->mirror() == 0, "should mirror ok");

my $newpatches = $mirror->newpatches();
ok((keys %$newpatches) == 3, "should yield 3 new patches");

# should update updateinfo.xml.gz
my $parser = SMT::Parser::RpmMdPatches->new();
$parser->resource("$tempdir");
my $patches = $parser->parse('repodata/updateinfo.xml.gz');
ok((keys %$newpatches) == 3, "updateinfo.xml.gz should now contain 3 patches");

#ok($mirror->statistic()->{TOTALFILES} != $mirror->statistic()->{UPTODATE}, "first mirror() should download all the files");
#ok($mirror->verify(), "mirrored data should pass checksum verifications");
#ok($mirror->mirror() == 0, "second mirror should work");
#ok($mirror->statistic()->{TOTALFILES} == $mirror->statistic()->{UPTODATE}, "second mirror() should not download anything");
