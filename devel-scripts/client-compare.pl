#!/usr/bin/perl

use strict;
use warnings;
use SMT::Utils;
use Text::ASCIITable;
use SMT;

my $dbh = SMT::Utils::db_connect();

my $statement = "";

if ( $SMT::SCHEMA_VERSION == 1.00 )
{
    $statement = "select cl.GUID, cl.HOSTNAME,
                         p.PRODUCT, p.VERSION, p.REL, p.ARCH, 
                         c.NAME, c.TARGET, c.LOCALPATH, c.CATALOGTYPE,
                         pc.OPTIONAL
                    from Products p, Catalogs c, ProductCatalogs pc
                         Clients cl, Registration r
                   where p.PRODUCTDATAID=pc.PRODUCTDATAID
                     and pc.CATALOGID=c.CATALOGID
                     and cl.GUID = r.GUID
                     and r.PRODUCTID = p.PRODUCTDATAID
                order by cl.GUID, p.PRODUCT, p.VERSION, p.REL, p.ARCH, c.NAME, c.TARGET; ";
}
else
{
    $statement = "select cl.GUID, cl.HOSTNAME,
                         p.PRODUCT, p.VERSION, p.REL, p.ARCH,
                         c.NAME, c.TARGET, c.LOCALPATH, c.CATALOGTYPE,
                         pc.OPTIONAL
                    from Products p, Catalogs c, ProductCatalogs pc,
                         Clients cl, Registration r
                   where p.ID=pc.PRODUCTID
                     and pc.CATALOGID=c.ID
                     and cl.GUID = r.GUID
                     and r.PRODUCTID = p.ID
                    order by cl.GUID, p.PRODUCT, p.VERSION, p.REL, p.ARCH, c.NAME, c.TARGET; ";
}

my $res = $dbh->selectall_arrayref($statement, {Slice=>{}});

my $t = new Text::ASCIITable;
$t->setCols( "Client ID", "HOSTNAME", "PRODUCT", "CATALOG", "LOCALPATH", "OPT", "CT" );
$t->addRow( '---', '----------',
'-----------------------------------------------------------------------------------------', 
'---------------------------------------------------------',
'--------------------------------------------------------------', '-' ); 

foreach my $set (@{$res})
{
    $set->{VERSION} = "" if(!defined $set->{VERSION});
    $set->{REL} = "" if(!defined $set->{REL});
    $set->{ARCH}= "" if(!defined $set->{ARCH});
    $set->{TARGET}= "" if(!defined $set->{TARGET});
    $t->addRow( $set->{GUID},
                $set->{HOSTNAME},
                $set->{PRODUCT}." ".$set->{VERSION}." ".$set->{REL}." ".$set->{ARCH},
                $set->{NAME}." ".$set->{TARGET},
                $set->{LOCALPATH},
                $set->{OPTIONAL},
                $set->{CATALOGTYPE});
}
print $t->draw();



