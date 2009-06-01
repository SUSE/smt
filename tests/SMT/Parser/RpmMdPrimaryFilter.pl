#! /usr/bin/perl -w

BEGIN {
    push @INC, "../www/perl-lib";
}

use strict;
use Cwd;
#use File::Temp;

use SMT::Parser::RpmMdPrimaryFilter;
use Test::Simple tests => 3;
use Data::Dumper;

#my $fh = new File::Temp(); # file to write the new metadata
my $wd = Cwd::cwd();       # current working dir

# packages to remove
my @remove = (
    {name => 'logwatch', ver => '7.3.6', rel => '60.6.1', arch => 'noarch'},
    {name => 'audacity', ver => '1.3.5', rel => '49.12.1', arch => 'i586'}
    );

my $parser = SMT::Parser::RpmMdPrimaryFilter->new(); #out => $fh); use $fh if test of the written file is needed
$parser->resource($wd . '/testdata/rpmmdtest/code11repo'); # FIXME this should use the testdir
$parser->parse(\@remove);

#$fh->flush;

my $parsed = $parser->found();

ok ((keys %$parsed) == 2);
my $pkgid = 'f7cb8f0f00d3434f723e4681b5cc6c5bef937463';
ok(exists $parsed->{$pkgid} &&
   $parsed->{$pkgid}->{name} eq 'logwatch' &&
   $parsed->{$pkgid}->{epo} eq '0' &&
   $parsed->{$pkgid}->{ver} eq '7.3.6' &&
   $parsed->{$pkgid}->{rel} eq '60.6.1' &&
   $parsed->{$pkgid}->{arch} eq 'noarch');
$pkgid = '1e6928c73b0409064f05f5af87af2a79b4f64dc9';
ok(exists $parsed->{$pkgid} &&
   $parsed->{$pkgid}->{name} eq 'audacity' &&
   $parsed->{$pkgid}->{epo} eq '0' &&
   $parsed->{$pkgid}->{ver} eq '1.3.5' &&
   $parsed->{$pkgid}->{rel} eq '49.12.1' &&
   $parsed->{$pkgid}->{arch} eq 'i586');
