package SMT::Product;

use strict;
use warnings;
use XML::Simple;

use SMT::Utils;

# returns XML for /products REST GET request
sub getAllAsXML
{
    my $dbh = shift;
    
    my $sql = "select productdataid, product, version, rel, arch, friendly from Products;";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my $data = { product => []};
    while (my $p = $sth->fetchrow_hashref())
    {
        # <product id="%s" name="%s" version="%s" rel="%s" arch="%s" uiname="%s"/>
        push @{$data->{product}}, {
            id => $p->{productdataid},
            name => $p->{product},
            version => $p->{version},
            rel => $p->{rel},
            arch => $p->{arch},
            uiname => $p->{friendly}
            };
    }
    return XMLout($data,
        rootname => 'products',
        xmldecl => '<?xml version="1.0" encoding="UTF-8" ?>');
}

1;
