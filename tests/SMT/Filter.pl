#!/usr/bin/perl

BEGIN {
    push @INC, "../www/perl-lib";
}

use Test::Simple tests => 5;

use SMT::Filter;
use Data::Dumper;

my $filter = SMT::Filter->new();
$filter->add(SMT::Filter->TYPE_NAME_VERSION, 'ha-20');
$filter->add(SMT::Filter->TYPE_NAME_VERSION, 'fa-12');
$filter->add(SMT::Filter->TYPE_NAME_VERSION, 'fa-12');
$filter->add(SMT::Filter->TYPE_NAME_REGEX, '^f');
$filter->add(SMT::Filter->TYPE_NAME_REGEX, 'masa.crex');

$patch = {
    name => 'fa',
    version => '12',
    category => 'recommended',
    title => 'patch for fa'
};

$patch2 = {
    name => 'faraway',
    version => '99',
    category => 'optional',
    title => 'patch for faraway'
};

ok ($filter->matches($patch), "patch fa-12 should match the filter");
ok ($filter->matches($patch2), "patch faraway-99 should not match the filter");

my $wm = $filter->whatMatches($patch);
my $found = 0;
for (@$wm)
{
    if ($_->[0] == SMT::Filter->TYPE_NAME_REGEX &&
        $_->[1] eq '^f')
    {
        $found = 1;
        last;
    } 
}
ok ($found, 'regex filter \'^f\' should match patch fa-12' );
$found = 0;
for (@$wm)
{
    if ($_->[0] == SMT::Filter->TYPE_NAME_VERSION &&
        $_->[1] eq 'fa-12')
    {
        $found = 1;
        last;
    } 
}
ok ($found, 'patch id filter \'fa-12\' should match patch fa-12');

$filter->clean();
ok ($filter->empty(), "should be empty after clean()");

#$filter->save($dbh, $cid);
#$f2->load($dbh, $cid);