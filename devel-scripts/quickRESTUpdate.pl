#!/bin/bash

# empty prefix for relative paths
PRE=.

cp -av $PRE/www/perl-lib/SMT/REST*pm  /srv/www/perl-lib/SMT/
cp -av $PRE/www/perl-lib/SMT/Client/Auth.pm  /srv/www/perl-lib/SMT/Client/
cp -av $PRE/www/perl-lib/SMT/Job[Q\.]*pm  /usr/lib/perl5/vendor_perl/5.10.0/SMT/
cp -av $PRE/www/perl-lib/SMT/Client.pm  /usr/lib/perl5/vendor_perl/5.10.0/SMT/
cp -av $PRE/www/perl-lib/SMT.pm  /usr/lib/perl5/vendor_perl/5.10.0/
cp -av $PRE/script/smt*  /usr/sbin/
cp -av $PRE/cron/smt* /usr/lib/SMT/bin/
chmod 755 /usr/sbin/smt*


# enable to restart apache after copying new files
# rcapache2 restart
