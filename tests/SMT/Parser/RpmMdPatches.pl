#! /usr/bin/perl -w

BEGIN {
    push @INC, "../www/perl-lib";
}

use strict;
use Test::Simple tests => 6;
use Cwd;
#use File::Temp;

use SMT::Parser::RpmMdPatches;
use SMT::Filter;

use Data::Dumper;


#my $fh = new File::Temp(); # file to write the new metadata
my $wd = Cwd::cwd();       # current working dir

my $filter = SMT::Filter->new();
$filter->add(SMT::Filter->TYPE_NAME_VERSION, 'imap-368');
$filter->add(SMT::Filter->TYPE_NAME_VERSION, 'perl-DBD-mysql-543');

my $parser = SMT::Parser::RpmMdPatches->new(
    filter => $filter,
    savefiltered => 1,
    savepackages => 1
    #out => $fh # use $fh if test of the written file is needed
    );
$parser->resource($wd . '/testdata/rpmmdtest/code11repo'); # FIXME this should use the testdir
my $patches = $parser->parse('repodata/updateinfo.xml.gz');

#$fh->flush;

ok((keys %$patches) == 3);
ok(
    defined $patches->{'audacity-523'} &&
    defined $patches->{'logwatch-658'} &&
    defined $patches->{'sudo-472'}
);
ok (
    defined $patches->{'audacity-523'} &&
    $patches->{'audacity-523'}->{name} eq 'audacity' &&
    $patches->{'audacity-523'}->{version} eq '523' &&
    $patches->{'audacity-523'}->{type} eq 'security' &&
    $patches->{'audacity-523'}->{title} eq 'audacity security update' &&
    $patches->{'audacity-523'}->{description} eq 'Specially crafted GRO files could cause a stack based
buffer in audacity (CVE-2009-0490).
'
);

my $filtered = $parser->filtered();
ok ((keys %$filtered) == 2);

my $filteredpkgs = $parser->filteredpkgs();
ok (@$filteredpkgs == 9);

ok (
    $filteredpkgs->[0]->{name} eq 'imap-devel' &&
    ! defined $filteredpkgs->[0]->{epo} &&
    $filteredpkgs->[0]->{ver} eq '2006c1_suse' &&
    $filteredpkgs->[0]->{rel} eq '127.1' &&
    $filteredpkgs->[0]->{arch} eq 'i586'
);

# TODO test code10 repo (patches.xml, patch-*.xml)