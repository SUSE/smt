NAME         = smt
VERSION      = 0.2.1
SCHEMA_VERSION = 0.02
DESTDIR      = /
PERL        ?= perl
PERLMODDIR   = $(shell $(PERL) -MConfig -e 'print $$Config{installvendorlib};')
SMT_SQLITE_DB = $(DESTDIR)/var/lib/SMT/db/smt.db
TEMPF = $(shell mktemp)

install_all: install install_conf install_db
	@echo "==========================================================="
	@echo "Append 'perl' to APACHE_MODULES an 'SSL' to APACHE_SERVER_FLAGS"
	@echo "in /etc/sysconfig/apache2 ."
	@echo "Required packages:"
	@echo "* apache2"
	@echo "* apache2-mod_perl"
	@echo "* mysql"
	@echo "* perl-DBI"
	@echo "* perl-DBD-mysql"
	@echo "* perl-Crypt-SSLeay"
	@echo "* perl-Config-IniFiles"
	@echo "* perl-XML-Parser"
	@echo "* perl-XML-Writer"
	@echo "* perl-libwww-perl"
	@echo "* perl-IO-Zlib"
	@echo "* perl-URI"
	@echo "* perl-TimeDate"
	@echo "* perl-Text-ASCIITable"
	@echo " "
	@echo "Finaly start the web server with 'rcapache2 start'"
	@echo "==========================================================="

install_db: install_db_mysql

install_db_sqlite:
	mkdir -p $(DESTDIR)/var/lib/SMT/db/
	cd db/
	sqlite3 -line $(SMT_SQLITE_DB) ".read db/smt-tables_sqlite.sql"
	sqlite3 -line $(SMT_SQLITE_DB) ".read db/products.sql"
	sqlite3 -line $(SMT_SQLITE_DB) ".read db/targets.sql"
	sqlite3 -line $(SMT_SQLITE_DB) ".read db/tmp-catalogs.sql"
	sqlite3 -line $(SMT_SQLITE_DB) ".read db/tmp-productcatalogs.sql"
	sqlite3 -line $(SMT_SQLITE_DB) ".read db/tmp-register.sql"
# this table is dropped
#	sqlite3 -line $(SMT_SQLITE_DB) ".read db/product_dependencies.sql"

install_db_mysql:
	echo "drop database if exists smt;" | mysql -u root
	echo "create database if not exists smt;" | mysql -u root
	cat db/smt-tables_mysql.sql | mysql -u root smt
	cat db/products.sql | mysql -u root smt
	cat db/targets.sql | mysql -u root smt
	cat db/tmp-catalogs.sql | mysql -u root smt
	cat db/tmp-productcatalogs.sql | mysql -u root smt
	cat db/tmp-register.sql | mysql -u root smt
# this table is dropped
#	cat db/product_dependencies.sql | mysql -u root smt

install_conf:
	mkdir -p $(DESTDIR)/etc/
	cp config/smt.conf $(DESTDIR)/etc/
	mkdir -p $(DESTDIR)/etc/init.d/

install:
	mkdir -p $(DESTDIR)/usr/sbin/
	mkdir -p $(DESTDIR)/etc/apache2
	mkdir -p $(DESTDIR)/etc/init.d
	mkdir -p $(DESTDIR)/etc/smt.d/
	mkdir -p $(DESTDIR)/etc/logrotate.d/
	mkdir -p $(DESTDIR)/srv/www/htdocs/repo
	mkdir -p $(DESTDIR)/srv/www/htdocs/testing/repo
	mkdir -p $(DESTDIR)/srv/www/perl-lib/NU
	mkdir -p $(DESTDIR)/srv/www/perl-lib/SMT
	mkdir -p $(DESTDIR)$(PERLMODDIR)/SMT/Mirror
	mkdir -p $(DESTDIR)$(PERLMODDIR)/SMT/Parser
	mkdir -p $(DESTDIR)/usr/share/schemas/smt
	mkdir -p $(DESTDIR)/usr/share/schemas/smt/mysql
	mkdir -p $(DESTDIR)/usr/share/schemas/smt/_common
	mkdir -p $(DESTDIR)/usr/lib/SMT/bin/
	cp apache2/smt-mod_perl-startup.pl $(DESTDIR)/etc/apache2/
	cp apache2/conf.d/*.conf $(DESTDIR)/etc/smt.d/
	cp apache2/vhosts.d/*.conf $(DESTDIR)/etc/smt.d/
	cp script/smt $(DESTDIR)/usr/sbin/
	cp script/smt-* $(DESTDIR)/usr/sbin/
	chmod 0755 $(DESTDIR)/usr/sbin/smt
	chmod 0755 $(DESTDIR)/usr/sbin/smt-*
	cp www/perl-lib/NU/*.pm $(DESTDIR)/srv/www/perl-lib/NU/
	cp www/perl-lib/SMT/Registration.pm $(DESTDIR)/srv/www/perl-lib/SMT/
	cp www/perl-lib/SMT/Utils.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	cp www/perl-lib/SMT/NCCRegTools.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	cp www/perl-lib/SMT/Mirror/*.pm /$(DESTDIR)$(PERLMODDIR)/SMT/Mirror/
	cp www/perl-lib/SMT/Parser/*.pm /$(DESTDIR)$(PERLMODDIR)/SMT/Parser/
	cp www/perl-lib/SMT/CLI.pm /$(DESTDIR)$(PERLMODDIR)/SMT/
	cp www/perl-lib/SMT.pm $(DESTDIR)$(PERLMODDIR)
	cp -R db/schemas/mysql/current $(DESTDIR)/usr/share/schemas/smt/mysql/$(SCHEMA_VERSION)
	cp -R db/schemas/common/current $(DESTDIR)/usr/share/schemas/smt/_common/$(SCHEMA_VERSION)
	if [ -e db/schemas/mysql/migrate/* ]; then cp -R db/schemas/mysql/migrate/* $(DESTDIR)/usr/share/schemas/smt/mysql/; fi
	if [ -e db/schemas/common/migrate/* ]; then cp -R db/schemas/common/migrate/* $(DESTDIR)/usr/share/schemas/smt/_common/; fi
	cp config/rc.smt $(DESTDIR)/etc/init.d/smt
	if [ -e $(DESTDIR)/usr/sbin/rcsmt ]; then rm -f $(DESTDIR)/usr/sbin/rcsmt; fi
	ln -s /etc/init.d/smt $(DESTDIR)/usr/sbin/rcsmt
	cp db/smt-db $(DESTDIR)/usr/lib/SMT/bin/smt-db
	chmod 0755 $(DESTDIR)/usr/lib/SMT/bin/smt-db
	chmod 0755 $(DESTDIR)/etc/init.d/smt
	install -m 644 cron/novell.com-smt $(DESTDIR)/etc/smt.d/
	install -m 755 cron/smt-logrun $(DESTDIR)/usr/lib/SMT/bin/
	install -m 755 cron/smt-daily $(DESTDIR)/usr/lib/SMT/bin/
	install -m 755 cron/smt-repeated-register $(DESTDIR)/usr/lib/SMT/bin/
	install -m 644 logrotate/smt $(DESTDIR)/etc/logrotate.d/

test: clean
	cd tests; perl tests.pl && cd -

clean:
	find . -name "*~" -print0 | xargs -0 rm -f
	rm -rf tests/testdata/rpmmdtest/*
	rm -rf $(NAME)-$(VERSION)/
	rm -rf $(NAME)-$(VERSION).tar.bz2


dist: clean
	rm -rf $(NAME)-$(VERSION)/
	@mkdir -p $(NAME)-$(VERSION)/apache2/conf.d/
	@mkdir -p $(NAME)-$(VERSION)/apache2/vhosts.d/
	@mkdir -p $(NAME)-$(VERSION)/config
	@mkdir -p $(NAME)-$(VERSION)/cron
	@mkdir -p $(NAME)-$(VERSION)/db
	@mkdir -p $(NAME)-$(VERSION)/doc
	@mkdir -p $(NAME)-$(VERSION)/script
	@mkdir -p $(NAME)-$(VERSION)/tests/SMT/Mirror
	@mkdir -p $(NAME)-$(VERSION)/tests/testdata/jobtest
	@mkdir -p $(NAME)-$(VERSION)/tests/testdata/rpmmdtest
	@mkdir -p $(NAME)-$(VERSION)/tests/testdata/regdatatest
	@mkdir -p $(NAME)-$(VERSION)/www/
	@mkdir -p $(NAME)-$(VERSION)/logrotate

	@cp apache2/*.pl $(NAME)-$(VERSION)/apache2/
	@cp apache2/conf.d/*.conf $(NAME)-$(VERSION)/apache2/conf.d/
	@cp apache2/vhosts.d/*.conf $(NAME)-$(VERSION)/apache2/vhosts.d/
	@cp config/smt.conf.production $(NAME)-$(VERSION)/config/smt.conf
	@cp config/rc.smt $(NAME)-$(VERSION)/config/
	@cp cron/smt-* $(NAME)-$(VERSION)/cron/
	@cp cron/novell.com-smt $(NAME)-$(VERSION)/cron/
	find db -name ".svn" -prune -o \
                \( \
                  \( -type d -exec install -m755 -d $(NAME)-$(VERSION)/\{\} \; \) \
                  -o \
                  \( -type f -exec install -m644 \{\} $(NAME)-$(VERSION)/\{\} \; \) \
                \)
	@cp doc/* $(NAME)-$(VERSION)/doc/
	@cp tests/*.pl $(NAME)-$(VERSION)/tests/
	@cp tests/SMT/Mirror/*.pl $(NAME)-$(VERSION)/tests/SMT/Mirror/
	@cp -r tests/testdata/regdatatest/* $(NAME)-$(VERSION)/tests/testdata/regdatatest/
	@cp www/README $(NAME)-$(VERSION)/www/
	@cp script/* $(NAME)-$(VERSION)/script/
	@cp logrotate/smt $(NAME)-$(VERSION)/logrotate/
	find www -name ".svn" -prune -o \
                \( \
                  \( -type d -exec install -m755 -d $(NAME)-$(VERSION)/\{\} \; \) \
                  -o \
                  \( -type f -exec install -m644 \{\} $(NAME)-$(VERSION)/\{\} \; \) \
                \)
	@cp HACKING Makefile README COPYING $(NAME)-$(VERSION)/

	tar cfvj $(NAME)-$(VERSION).tar.bz2 $(NAME)-$(VERSION)/

pot:
	find www/ -name "*.pm" > sourcefiles
	find script/ -maxdepth 1 -name "smt*" >> sourcefiles
	xgettext --default-domain=smt --directory=. --keyword=__ -o smt.pot --files-from sourcefiles
	rm -f sourcefiles
