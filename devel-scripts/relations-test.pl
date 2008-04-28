#!/usr/bin/perl

use strict;
use warnings;
use SMT::Utils;
use Text::ASCIITable;


my $dbh = SMT::Utils::db_connect();

my $statement = "select p.PRODUCT, p.VERSION, p.REL, p.ARCH, c.NAME, c.TARGET, pc.OPTIONAL, pc.PRODUCTDATAID, pc.CATALOGID from Products p, Catalogs c, ProductCatalogs pc where p.PRODUCTDATAID=pc.PRODUCTDATAID and pc.CATALOGID=c.CATALOGID order by p.PRODUCT, p.VERSION, p.REL, p.ARCH, c.NAME, c.TARGET; ";

my $res = $dbh->selectall_arrayref($statement, {Slice=>{}});

my $t = new Text::ASCIITable;
$t->setCols( "PRODID", "CATALOGID", "PRODUCT", "CATALOG", "OPT" );

foreach my $set (@{$res})
{
    $set->{VERSION} = "" if(!defined $set->{VERSION});
    $set->{REL} = "" if(!defined $set->{REL});
    $set->{ARCH}= "" if(!defined $set->{ARCH});
    $set->{TARGET}= "" if(!defined $set->{TARGET});
    $t->addRow( $set->{PRODUCTDATAID}, $set->{CATALOGID}, $set->{PRODUCT}." ".$set->{VERSION}." ".$set->{REL}." ".$set->{ARCH}, $set->{NAME}."/".$set->{TARGET}, $set->{OPTIONAL});
} 
print $t->draw();



