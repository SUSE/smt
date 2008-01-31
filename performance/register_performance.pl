#! /usr/bin/perl -w

#
# Copyright (c) 2006 SUSE LINUX Products GmbH, Nuernberg, Germany.
#

BEGIN 
{
    unshift @INC, ".";
    unshift @INC, "..";
}

use strict;
use Data::Dumper;
use Getopt::Long;
use Encode;
use Time::HiRes qw(gettimeofday tv_interval);
use Sys::Syslog;
use Register;
use File::Copy;


my $listParams = 0;

sub logPrintExit
{
    my $ctx = shift;
    my $message = shift || undef;
    my $code    = shift || 42;

    if(exists $ctx->{args}->{password})
    {
        $ctx->{args}->{password}->{value} = "secret";
    }
    if(exists $ctx->{args}->{passwd})
    {
        $ctx->{args}->{passwd}->{value} = "secret";
    }
    if(exists $ctx->{args}->{secret})
    {
        $ctx->{args}->{secret}->{value} = "secret";
    }
    my $cmdtxt = "Commandline params: no-optional:$ctx->{nooptional}  forceregistration:$ctx->{forcereg}  ";
    $cmdtxt .= "no-hw-data:$ctx->{nohwdata} batch:$ctx->{batch} ";

    syslog("err", $cmdtxt);
    syslog("err", "Argument Dump: ".Data::Dumper->Dump([$ctx->{args}]));
    syslog("err", "Products Dump: ".Data::Dumper->Dump([$ctx->{products}]));
    syslog("err", "$message($code)");
    print STDERR $message;

    closelog;
    close $ctx->{LOGDESCR} if(defined $ctx->{LOGDESCR});

    exit $code;
}

open(PERF, ">> ./performance.log") or do 
{
    die "Cannot open logfile: $!";
};

print "GUID\t| Time\n";
print PERF "GUID\t| Time\n";

for( my $cnt = 0; $cnt < 10000; $cnt++)
{
    my $t0 = [gettimeofday];

    my $data = {};
    $data->{debug} = 0;
    
    my $ctx = Register::init_ctx($data);
    if($ctx->{errorcode} != 0)
    {
        logPrintExit($ctx, $ctx->{errormsg}, $ctx->{errorcode});
    }

    $ctx->{guid} = "$cnt";
    

    my $ret = 0;

    if ($listParams)
    {
        $ret = Register::listParams($ctx);
        if($ctx->{errorcode} != 0)
        {
            logPrintExit($ctx, $ctx->{errormsg}, $ctx->{errorcode});
        }
        
        print $ret;
    }
    else 
    {
        $ret = Register::register($ctx);
        if($ctx->{errorcode} != 0)
        {
            logPrintExit($ctx, $ctx->{errormsg}, $ctx->{errorcode});
        }
        
        #print Data::Dumper->Dump([$ctx])."\n";
        
        
        # clean lastResponse only in this case. When this register
        # call returns only interactive needinfos the next will fail.
        $ctx->{lastResponse} = "";
        
        
        if($ret == 1)
        {
            $ret = Register::register($ctx);
            if($ctx->{errorcode} != 0)
            {
                logPrintExit($ctx, $ctx->{errormsg}, $ctx->{errorcode});
            }
            
            if($ret == 1)
            {
                print STDERR join("", @{$ctx->{registerReadableText}})."\n";
                print $ctx->{registerManuallyURL}."\n";
                exit 1;
            }
        }
    }

    print PERF "$cnt\t|".(tv_interval($t0))."\n";
    print "$cnt\t|".(tv_interval($t0))."\n";
}

close PERF;

exit 0;
