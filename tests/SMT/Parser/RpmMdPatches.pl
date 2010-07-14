#! /usr/bin/perl -w

BEGIN {
    push @INC, "../www/perl-lib";
}

use strict;
use Test::Simple tests => 11;
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
' &&
    $patches->{'audacity-523'}->{date} == 1234447476 &&
    $patches->{'audacity-523'}->{targetrel} eq 'openSUSE 11.1'
);

ok (defined $patches->{'audacity-523'} &&
    $patches->{'audacity-523'}->{refs}->[0]->{id} == 474258 &&
    $patches->{'audacity-523'}->{refs}->[0]->{type} eq 'bugzilla' &&
    $patches->{'audacity-523'}->{refs}->[0]->{href} eq 'https://bugzilla.novell.com/show_bug.cgi?id=474258',
    'audacity-523 should refer to BNC #474258');

print Dumper($patches->{'audacity-523'});

ok (defined $patches->{'audacity-523'} &&
    scalar @{$patches->{'audacity-523'}->{pkgs}} eq 3,
    'audacity-523 should contain 3 packages');

if (defined $patches->{'audacity-523'})
{
    foreach my $pkg (@{$patches->{'audacity-523'}->{pkgs}})
    {
      ok ($pkg->{name} eq 'audacity' &&
          $pkg->{ver} eq '1.3.5' &&
          $pkg->{rel} eq '49.12.1' &&
          $pkg->{arch} &&
          $pkg->{loc} eq $pkg->{name}.'-'.$pkg->{ver}.'-'.$pkg->{rel}.'.'.$pkg->{arch}.'.rpm',
          'individual patch package data test');
    }
}


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