#! /bin/sh

echo "select p.PRODUCTDATAID, p.PRODUCT, p.VERSION, p.REL, p.ARCH, p.PRODUCT_LIST from Products p where p.PRODUCTDATAID not in (select distinct pc.PRODUCTDATAID from ProductCatalogs pc) order by p.PRODUCTDATAID" | mysql -usmt -p smt -t

