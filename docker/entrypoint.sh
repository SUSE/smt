#!/bin/bash
set -e

# Render smt.conf from template
envsubst < /etc/smt.conf.template > /etc/smt.conf
chmod 640 /etc/smt.conf
chown root:www /etc/smt.conf

# Install SMT from source mounted at /usr/src/smt
echo "Installing SMT..."
make install

# Ensure mod_perl is loaded (sysconfig init not available in Docker)
MOD_PERL=$(find /usr/lib64/apache2 /usr/lib/apache2 -name "mod_perl.so" 2>/dev/null | head -1)

if [ -n "$MOD_PERL" ]; then
    echo "LoadModule perl_module $MOD_PERL" > /etc/apache2/conf.d/00-mod-perl.conf
fi

# Initialize or upgrade schema
SCHEMA_INITIALIZED=$(smt-sql --select-mode - <<< "SHOW TABLES LIKE 'migration_schema_version';" 2>/dev/null)

if [ -z "$SCHEMA_INITIALIZED" ]; then
    echo "Initializing fresh database schema..."
    SCHEMA_VERSION=$(perl -MSMT -e 'print $SMT::SCHEMA_VERSION')
    smt-sql /usr/share/schemas/smt/mysql/latest/100-smt-tables.sql
    smt-sql - <<< "INSERT INTO migration_schema_version VALUES ('smt', ${SCHEMA_VERSION});"
fi

chmod 644 /etc/zypp/credentials.d/SCCcredentials 2>/dev/null || true

echo "Running schema upgrade..."
/usr/bin/smt-schema-upgrade --yes

echo "Starting Apache..."
exec /usr/sbin/httpd -DFOREGROUND
