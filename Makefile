NAME          = smt
VERSION       = 1.1.5
DESTDIR       = /
PERL         ?= perl
PERLMODDIR    = $(shell $(PERL) -MConfig -e 'print $$Config{installvendorlib};')
SMT_SQLITE_DB = $(DESTDIR)/var/lib/SMT/db/smt.db
TEMPF         = $(shell mktemp)
DOCDIR        = /usr/share/doc/packages

all:
	make -C swig

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
	install -m 640 config/smt.conf $(DESTDIR)/etc/
	mkdir -p $(DESTDIR)/etc/init.d/

install:
	mkdir -p $(DESTDIR)/usr/sbin/
	mkdir -p $(DESTDIR)/etc/apache2
	mkdir -p $(DESTDIR)/etc/init.d
	mkdir -p $(DESTDIR)/etc/smt.d/
	mkdir -p $(DESTDIR)/etc/logrotate.d/
	mkdir -p $(DESTDIR)/srv/www/htdocs/repo/tools
	mkdir -p $(DESTDIR)/srv/www/htdocs/repo/keys
	mkdir -p $(DESTDIR)/srv/www/htdocs/repo/testing
	mkdir -p $(DESTDIR)/srv/www/htdocs/repo/full
	mkdir -p $(DESTDIR)/srv/www/perl-lib/NU
	mkdir -p $(DESTDIR)/srv/www/perl-lib/SMT
	mkdir -p $(DESTDIR)$(PERLMODDIR)/SMT/Mirror
	mkdir -p $(DESTDIR)$(PERLMODDIR)/SMT/Parser
	mkdir -p $(DESTDIR)$(PERLMODDIR)/SMT/Agent
	mkdir -p $(DESTDIR)/usr/share/schemas/smt
	mkdir -p $(DESTDIR)/usr/share/schemas/smt/mysql
	mkdir -p $(DESTDIR)/usr/share/schemas/smt/_common
	mkdir -p $(DESTDIR)/usr/lib/SMT/bin/
	mkdir -p $(DESTDIR)/usr/lib/SMT/bin/job/
	mkdir -p $(DESTDIR)$(DOCDIR)/smt
	install -m 644 apache2/smt-mod_perl-startup.pl $(DESTDIR)/etc/apache2/
	install -m 644 apache2/conf.d/*.conf $(DESTDIR)/etc/smt.d/
	install -m 644 apache2/vhosts.d/*.conf $(DESTDIR)/etc/smt.d/
	install -m 755 script/smt $(DESTDIR)/usr/sbin/
	install -m 755 script/smt-* $(DESTDIR)/usr/sbin/
	install -m 644 www/perl-lib/NU/*.pm $(DESTDIR)/srv/www/perl-lib/NU/
	install -m 644 www/perl-lib/SMT/Registration.pm $(DESTDIR)/srv/www/perl-lib/SMT/
	install -m 644 www/perl-lib/SMT/Support.pm $(DESTDIR)/srv/www/perl-lib/SMT/
	install -m 644 www/perl-lib/SMT/Utils.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/NCCRegTools.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/Mirror/*.pm /$(DESTDIR)$(PERLMODDIR)/SMT/Mirror/
	install -m 644 www/perl-lib/SMT/Parser/*.pm /$(DESTDIR)$(PERLMODDIR)/SMT/Parser/
	install -m 644 www/perl-lib/SMT/Agent/*.pm /$(DESTDIR)$(PERLMODDIR)/SMT/Agent/
	install -m 644 www/perl-lib/SMT/CLI.pm /$(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT.pm $(DESTDIR)$(PERLMODDIR)
	install -m 644 www/perl-lib/SMT/Filter.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/Repositories.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/JobQueue.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/Job.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/RESTService.pm $(DESTDIR)/srv/www/perl-lib/SMT/
	install -m 644 www/perl-lib/SMT/RESTInfo.pm $(DESTDIR)/srv/www/perl-lib/SMT/
	cd db/schemas; \
	find mysql/ -name ".svn" -prune -o \
                \( \
                  \( -type d -exec install -m755 -d $(DESTDIR)/usr/share/schemas/smt/\{\} \; \) \
                  -o \
                  \( -type f -exec install -m644 \{\} $(DESTDIR)/usr/share/schemas/smt/\{\} \; \) \
                \)
	cd db/schemas; \
        find _common/ -name ".svn" -prune -o \
                \( \
                  \( -type d -exec install -m755 -d $(DESTDIR)/usr/share/schemas/smt/\{\} \; \) \
                  -o \
                  \( -type f -exec install -m644 \{\} $(DESTDIR)/usr/share/schemas/smt/\{\} \; \) \
                \)
	install -m 755 config/rc.smt $(DESTDIR)/etc/init.d/smt
	if [ -e $(DESTDIR)/usr/sbin/rcsmt ]; then rm -f $(DESTDIR)/usr/sbin/rcsmt; fi
	ln -s /etc/init.d/smt $(DESTDIR)/usr/sbin/rcsmt
	install -m 755 db/smt-db $(DESTDIR)/usr/lib/SMT/bin/
	install -m 755 script/changeSMTUserPermissions.sh $(DESTDIR)/usr/lib/SMT/bin/
	install -m 755 script/clientSetup4SMT.sh $(DESTDIR)/srv/www/htdocs/repo/tools/
	install -m 644 www/repo/res-signingkeys.key $(DESTDIR)/srv/www/htdocs/repo/keys/
	install -m 644 cron/novell.com-smt $(DESTDIR)/etc/smt.d/
	install -m 644 cron/smt-cron.conf $(DESTDIR)/etc/smt.d/
	install -m 755 cron/smt-daily $(DESTDIR)/usr/lib/SMT/bin/
	install -m 755 cron/smt-gen-report $(DESTDIR)/usr/lib/SMT/bin/
	install -m 755 cron/smt-repeated-register $(DESTDIR)/usr/lib/SMT/bin/
	install -m 644 logrotate/smt $(DESTDIR)/etc/logrotate.d/
	install -m 755 script/processjob $(DESTDIR)/usr/lib/SMT/bin/
	install -m 755 script/softwarepush $(DESTDIR)/usr/lib/SMT/bin/job
	install -m 755 script/patchstatus $(DESTDIR)/usr/lib/SMT/bin/job

	install -m 644 README $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 COPYING $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 doc/High-Level-Architecture.odp $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 doc/Registrationdata-NCC-YEP.odt $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 doc/SMT-Database-Schema.odg $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 doc/NCC-Client-Registration-via-YEP.odt $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 doc/Server-Tuning.txt $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 doc/SMT-Database-Schema.txt $(DESTDIR)$(DOCDIR)/smt/
	make -C swig $@

	mkdir -p $(DESTDIR)/var/spool/smt-support
	chown smt:www $(DESTDIR)/var/spool/smt-support || echo "Set ownership manually: chown smt:www $(DESTDIR)/var/spool/smt-support"
	chmod 775 $(DESTDIR)/var/spool/smt-support || echo "Set permission manually: chmod 775 $(DESTDIR)/var/spool/smt-support"

test: clean
	cd tests; perl tests.pl && cd -

clean:
	find . -name "*~" -print0 | xargs -0 rm -f
	rm -rf tests/testdata/rpmmdtest/*
	rm -rf $(NAME)-$(VERSION)/
	rm -rf $(NAME)-$(VERSION).tar.bz2
	make -C swig $@

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
	@mkdir -p $(NAME)-$(VERSION)/www
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
	@cp doc/High-Level-Architecture.odp $(NAME)-$(VERSION)/doc/
	@cp doc/NCC-Client-Registration-via-YEP.odt $(NAME)-$(VERSION)/doc/
	@cp doc/Registrationdata-NCC-YEP.odt $(NAME)-$(VERSION)/doc/
	@cp doc/Server-Tuning.txt $(NAME)-$(VERSION)/doc/
	@cp doc/SMT-Database-Schema.odg $(NAME)-$(VERSION)/doc/
	@cp doc/SMT-Database-Schema.txt $(NAME)-$(VERSION)/doc/

	@cp tests/*.pl $(NAME)-$(VERSION)/tests/
	@cp tests/SMT/Mirror/*.pl $(NAME)-$(VERSION)/tests/SMT/Mirror/
	@cp -r tests/testdata/regdatatest/* $(NAME)-$(VERSION)/tests/testdata/regdatatest/
	@cp script/* $(NAME)-$(VERSION)/script/
	@cp logrotate/smt $(NAME)-$(VERSION)/logrotate/
	find www -name ".svn" -prune -o \
                \( \
                  \( -type d -exec install -m755 -d $(NAME)-$(VERSION)/\{\} \; \) \
                  -o \
                  \( -type f -exec install -m644 \{\} $(NAME)-$(VERSION)/\{\} \; \) \
                \)
	make -C swig NAME=$(NAME) VERSION=$(VERSION) $@
	@cp Makefile README COPYING $(NAME)-$(VERSION)/
	@rm $(NAME)-$(VERSION)/www/README

	tar cfvj $(NAME)-$(VERSION).tar.bz2 $(NAME)-$(VERSION)/

pot:
	find www/ -name "*.pm" > sourcefiles
	find script/ -maxdepth 1 -name "smt*" >> sourcefiles
	xgettext --default-domain=smt --directory=. --keyword=__ -o smt.pot --files-from sourcefiles
	rm -f sourcefiles
