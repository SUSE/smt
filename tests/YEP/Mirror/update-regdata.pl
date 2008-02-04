#! /usr/bin/perl -w

use strict;
use YEP::Mirror::RegData;
use Test::Simple tests => 5;

sub testsync
{
    my $self    = shift;
    my $xmlfile = shift;
    
    #my $xmlfile = $self->_requestData();
    if(!$xmlfile)
    {
        return 1;
    }
    
    $self->_parseXML($xmlfile);
    return $self->_updateDB();
}


my $rd = YEP::Mirror::RegData->new(debug   => 1,
                                   element => "productdata",
                                   table   => "Products",
                                   key     => "PRODUCTDATAID");
my $res = testsync($rd, "./testdata/regdatatest/productdata.xml");
if($res)
{
    print STDERR "Error while fetching Products data.\n";
}
ok($res == 0);

# this table is dropped
#
#$rd->element("productdep");
#$rd->table("ProductDependencies");
#$rd->key([ 'PARENT_PRODUCT_ID', 'CHILD_PRODUCT_ID']);

#$res = testsync($rd, "./testdata/regdatatest/productdep.xml");
#if($res)
#{
#    print STDERR "Error while fetching ProductDependencies data.\n";
#}
#ok($res == 0);

$rd->element("targets");
$rd->table("Targets");
$rd->key("OS");

$res = testsync($rd, "./testdata/regdatatest/targets.xml");
if($res)
{
    print STDERR "Error while fetching Targets data.\n";
}
ok($res == 0);

$rd->element("catalogs");
$rd->table("Catalogs");
$rd->key("CATALOGID");

$res = testsync($rd, "./testdata/regdatatest/catalogs.xml");
if($res)
{
    print STDERR "Error while fetching Catalogs data.\n";
}
ok($res == 0);

$rd->element("productcatalogs");
$rd->table("ProductCatalogs");
$rd->key(['PRODUCTDATAID', 'CATALOGID']);

$res = testsync($rd, "./testdata/regdatatest/productcatalogs.xml");
if($res)
{
    print STDERR "Error while fetching ProductCatalogs data.\n";
}
ok($res == 0);







