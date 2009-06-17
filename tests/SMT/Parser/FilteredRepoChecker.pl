#! /usr/bin/perl -w

BEGIN {
    push @INC, "../www/perl-lib";
}

use strict;
use Test::Simple tests => 6;
use Cwd;

#use SMT::Utils;
#use Data::Dumper;

use SMT::Parser::FilteredRepoChecker;


my $wd = Cwd::cwd();       # current working dir

#my $log = SMT::Utils::openLog('/local/jkupec/tmp/smt.log');
#my $vblevel = LOG_DEBUG|LOG_DEBUG2|LOG_WARN|LOG_ERROR|LOG_INFO1|LOG_INFO2;

my $checker = SMT::Parser::FilteredRepoChecker->new(); #log => $log, vblevel => $vblevel); 
$checker->repoPath($wd . '/testdata/rpmmdtest/sharedpkgs'); # FIXME this should use the testdir

my $filter = SMT::Filter->new();
$filter->add(SMT::Filter->TYPE_NAME_VERSION, 'imap-368');
$checker->filter($filter);

my ($result, $problems, $causes) = $checker->check();

#print Dumper($result, $problems, $causes);

ok (!$result);

ok (exists $problems->{'imap-lib-2006c1_suse-127.1'} &&
    $problems->{'imap-lib-2006c1_suse-127.1'} eq 'testsharedpkg-999');

ok (exists $causes->{'imap-lib-2006c1_suse-127.1'} &&
    $causes->{'imap-lib-2006c1_suse-127.1'} eq 'imap-368');

$filter->remove(SMT::Filter->TYPE_NAME_VERSION, 'imap-368');
$filter->add(SMT::Filter->TYPE_NAME_VERSION, 'logwatch-658');
($result, $problems, $causes) = $checker->check();

ok ($result);
ok (!%$problems);
ok (!%$causes);