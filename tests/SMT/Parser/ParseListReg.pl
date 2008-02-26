#! /usr/bin/perl -w

BEGIN {
    push @INC, "../www/perl-lib";
}

use strict;
use SMT::Parser::ListReg;
use Test::Simple tests => 3;
use Data::Dumper;

my $rd = SMT::Parser::ListReg->new();
$rd->parse("./testdata/regdatatest/registrations.xml", sub { test_handler(@_)});


sub test_handler
{
    my $data = shift;
    
    #print STDERR Data::Dumper->Dump([$data])."\n"; 

    ok(exists $data->{GUID});
}



                                                             
