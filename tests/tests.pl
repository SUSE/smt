#!/usr/bin/env perl

BEGIN {
    push @INC, "../www/perl-lib";
}

use File::Find;
use Test::Harness qw(&runtests);

my @tests;
find ( { wanted => 
  sub
  {
    if ( $_ =~ /\.pl$/ && $_ !~ /tests\.pl$/ )
    { push( @tests, $_); }
  }
  , no_chdir => 1 }, ".");

foreach ( @tests )
{
  print $_, "\n";
}
#@tests = @ARGV ? @ARGV : <*.pl>;
runtests @tests;
