#!/usr/bin/perl

BEGIN {
    push @INC, "../www/perl-lib";
}

use Test::Simple tests => 3;

use SMT::Filter;


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

$filter->clean();
ok ($filter->empty(), "should be empty after clean()");

#$filter->save($dbh, $cid);
#$f2->load($dbh, $cid);