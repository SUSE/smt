#! /usr/bin/perl -w

use strict;
use Time::HiRes qw(gettimeofday tv_interval);

open(PERF, ">> ./performance2.log") or do
{
    die "Cannot open logfile: $!";
};

print "GUID\t| Time\n";
print PERF "GUID\t| Time\n";

my ($start, $end);
$start=shift or $start=0;
$end=shift or $end=10000;

my $opts = shift || "";

if(! -x "./suse_register")
{
    die "./suse_register client not found";
}


for( my $cnt = $start; $cnt <= $end; $cnt++)
{
    my $t0 = [gettimeofday];
    
    `./suse_register --fakeguid $cnt $opts`;

    print PERF "$cnt\t|".(tv_interval($t0))."\n";
    print "$cnt\t|".(tv_interval($t0))."\n";
}

close PERF;

exit 0;
