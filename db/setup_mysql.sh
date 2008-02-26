#! /bin/sh

SMTDIR="/var/lib/SMT"

if [ `id -u` -ne 0 ]; then
    echo "You must be root to run this script";
    exit 1;
fi

STATUS=`/etc/init.d/mysql status`;
if [ $? -ne 0 ]; then
    /etc/init.d/mysql start
fi

echo "drop database if exists smt;" | mysql -u root
echo "create database if not exists smt;" | mysql -u root
cat $SMTDIR/db/smt-tables_mysql.sql | mysql -u root smt
cat $SMTDIR/db/products.sql | mysql -u root smt
cat $SMTDIR/db/targets.sql | mysql -u root smt
cat $SMTDIR/db/tmp-catalogs.sql | mysql -u root smt
cat $SMTDIR/db/tmp-productcatalogs.sql | mysql -u root smt
cat $SMTDIR/db/tmp-register.sql | mysql -u root smt

exit 0;
