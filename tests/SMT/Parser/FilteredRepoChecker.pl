#! /usr/bin/perl -w

BEGIN {
    push @INC, "../www/perl-lib";
}

use strict;
use Test::Simple tests => 1;
use Cwd;

#use SMT::Utils;
#use Data::Dumper;

use SMT::Parser::FilteredRepoChecker;


my $wd = Cwd::cwd();       # current working dir

#my $log = SMT::Utils::openLog('/local/jkupec/tmp/smt.log');
#my $vblevel = LOG_DEBUG|LOG_DEBUG2|LOG_WARN|LOG_ERROR|LOG_INFO1|LOG_INFO2;

my $checker = SMT::Parser::FilteredRepoChecker->new(); #log => $log, vblevel => $vblevel); 
$checker->repoPath($wd . '/testdata/rpmmdtest/code11repo'); # FIXME this should use the testdir

my $filter = SMT::Filter->new();
$filter->add(SMT::Filter->TYPE_NAME_VERSION, 'logwatch-658');
$checker->filter($filter);

my ($result, $problems, $causes) = $checker->check();

ok ($result);

# TODO: needs better test case repo (for negative case)
