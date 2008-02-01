#! /bin/sh

YEPDIR="/var/lib/YEP"

if [ `id -u` -ne 0 ]; then
    echo "You must be root to run this script";
    exit 1;
fi

STATUS=`/etc/init.d/mysql status`;
if [ $? -ne 0 ]; then
    /etc/init.d/mysql start
fi

echo "drop database if exists yep;" | mysql -u root
echo "create database if not exists yep;" | mysql -u root
cat $YEPDIR/db/yep-tables_mysql.sql | mysql -u root yep
cat $YEPDIR/db/products.sql | mysql -u root yep
cat $YEPDIR/db/product_dependencies.sql | mysql -u root yep
cat $YEPDIR/db/targets.sql | mysql -u root yep
cat $YEPDIR/db/tmp-catalogs.sql | mysql -u root yep
cat $YEPDIR/db/tmp-productcatalogs.sql | mysql -u root yep
cat $YEPDIR/db/tmp-register.sql | mysql -u root yep

exit 0;