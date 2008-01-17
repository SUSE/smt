#!/usr/bin/env perl

use YEP::Parser::NU;
use Test::Simple tests => 6;

my $counter = 0;

sub handler()
{
    my $data = shift;
    #print STDERR " - " .$data->{NAME} ." REPO\n";
    if ($counter == 0 )
    {
        ok($data->{NAME} eq "SLE10-SDK-Updates");
        ok($data->{DISTRO_TARGET} eq "sles-10-i586");
        ok($data->{PATH} eq "\$RCE/SLE10-SDK-Updates/sles-10-i586");
        ok($data->{DESCRIPTION} eq "SLE10-SDK-Updates for sles-10-i586");
        ok($data->{PRIORITY} == 0);
    }
    $counter += 1;

}

$parser = YEP::Parser::NU->new();
$parser->parse("./testdata/repoindex.xml", \&handler);

# the data file contains 70 entries
#print STDERR " - " .$counter ." ENTRIES\n";
ok($counter == 70);


