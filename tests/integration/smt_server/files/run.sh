#!/bin/bash

SMT_CONFIG=/etc/smt.conf

while ! exec 6<>/dev/tcp/db/3306; do
    echo "$(date) - still trying to connect to MySQL at db linked container"
    sleep 1
done

sed -i "s|^NURegUrl=.*$|NURegUrl=${SCC_REGSERVER_URL}|" $SMT_CONFIG
sed -i "s/^NUUser=.*$/NUUser=${SCC_USERNAME}/" $SMT_CONFIG
sed -i "s/^NUPass=.*$/NUPass=${SCC_PASSWORD}/" $SMT_CONFIG
grep -q ApiType=SCC $SMT_CONFIG || sed -i "/NUPass=${SCC_PASSWORD}/a ApiType=SCC" $SMT_CONFIG
sed -i "s/^config=dbi.*$/config=dbi:mysql:database=smt;host=db/" $SMT_CONFIG
sed -i "s/^user=.*$/user=${SMT_DB_USER}/" $SMT_CONFIG
sed -i "s/^pass=.*$/pass=${SMT_DB_PASSWORD}/" $SMT_CONFIG
sed -i "s/^url=.*$/url=http:\/\/${HOSTNAME}/" $SMT_CONFIG

mysql -h db -u root -p${MYSQL_ROOT_PASSWORD} -e "DROP DATABASE IF EXISTS smt; CREATE DATABASE smt;"
mysql -h db -u root -p${MYSQL_ROOT_PASSWORD} -e "DROP USER $SMT_DB_USER;"
mysql -h db -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER '$SMT_DB_USER'@'%' identified by '$SMT_DB_PASSWORD';"
mysql -h db -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL ON *.* TO '$SMT_DB_USER'@'%';"

# Preload SMT Schema
mysql -h db -u${SMT_DB_USER} -p${SMT_DB_PASSWORD} -D smt < /usr/share/schemas/smt/mysql/latest/100-smt-tables.sql

smt-sync
smt-repos --enable-by-prod SLES,12.2,x86_64

echo "OK" > /srv/www/htdocs/status

exec "$@"
