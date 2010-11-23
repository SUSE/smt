#!/usr/bin/perl

BEGIN {
    push @INC, "../www/perl-lib";
}

use Test::Simple tests => 1;

use SMT::Patch;
use Data::Dumper;

my $patch = SMT::Patch::new();
$patch->setFromHash({name=>'mypatch', version=>'1.2.3', title=>'My Patch', type=>'security', description=>undef});

ok ($patch->asXML() =~ '<description>', 'The <description> tag must be present even if description is empty.');
