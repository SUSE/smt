#!/usr/bin/env perl

use Test::Harness qw(&runtests);
@tests = @ARGV ? @ARGV : <*.pl>;
runtests @tests;