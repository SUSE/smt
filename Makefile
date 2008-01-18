NAME         = yep
VERSION      = 0.0.2
DESTDIR      = /
PERL        ?= perl
PERLMODDIR   = $(shell $(PERL) -MConfig -e 'print $$Config{installvendorlib};')

install_all: install install_conf install_db
	@echo "==========================================================="
	@echo "Append 'perl' to APACHE_MODULES an 'SSL' to APACHE_SERVER_FLAGS"
	@echo "in /etc/sysconfig/apache2 ."
	@echo "Required packages:"
	@echo "* apache2"
	@echo "* apache2-mod_perl"
	@echo "* sqlite"
	@echo "* perl-DBI"
	@echo "* perl-DBD-SQLite"
	@echo "* perl-Crypt-SSLeay"
	@echo "* perl-Config-IniFiles"
	@echo "* perl-XML-Parser"
	@echo "* perl-XML-Writer"
	@echo "* perl-libwww-perl"
	@echo "* perl-IO-Zlib"
	@echo "* perl-URI"
	@echo "* perl-TimeDate"
	@echo " "
	@echo "chown wwwrun.www /var/lib/YEP/db/"
	@echo "chown wwwrun.www $(DESTDIR)/var/lib/YEP/db/yep.db"
	@echo " "
	@echo "Finaly start the web server with 'rcapache2 start'"
	@echo "==========================================================="

install_db:
	mkdir -p $(DESTDIR)/var/lib/YEP/db/
	cd db; sqlite3 -init setupdb.init $(DESTDIR)/var/lib/YEP/db/yep.db '.exit'; cd -

install_conf:
	mkdir -p $(DESTDIR)/etc/
	cp config/yep.conf $(DESTDIR)/etc/

install:
	mkdir -p $(DESTDIR)/usr/bin/
	mkdir -p $(DESTDIR)/etc/apache2/conf.d/
	mkdir -p $(DESTDIR)/etc/apache2/vhosts.d/
	mkdir -p $(DESTDIR)/srv/www/htdocs/repo
	mkdir -p $(DESTDIR)/srv/www/htdocs/testing/repo
	mkdir -p $(DESTDIR)/srv/www/perl-lib/NU
	mkdir -p $(DESTDIR)/srv/www/perl-lib/YEP
	mkdir -p $(DESTDIR)$(PERLMODDIR)/YEP/Mirror
	mkdir -p $(DESTDIR)$(PERLMODDIR)/YEP/Parser
	cp apache2/yep-mod_perl-startup.pl $(DESTDIR)/etc/apache2/
	cp apache2/conf.d/*.conf $(DESTDIR)/etc/apache2/conf.d/
	cp apache2/vhosts.d/*.conf $(DESTDIR)/etc/apache2/vhosts.d/
	cp script/yep-mirror.pl $(DESTDIR)/usr/bin/
	cp script/yepdb $(DESTDIR)/usr/bin/
	chmod 0755 $(DESTDIR)/usr/bin/yep-mirror.pl
	chmod 0755 $(DESTDIR)/usr/bin/yepdb
	cp www/perl-lib/NU/*.pm $(DESTDIR)/srv/www/perl-lib/NU/
	cp www/perl-lib/YEP/Registration.pm $(DESTDIR)/srv/www/perl-lib/YEP/
	cp www/perl-lib/YEP/Utils.pm $(DESTDIR)$(PERLMODDIR)/YEP/
	cp www/perl-lib/YEP/Mirror/*.pm /$(DESTDIR)$(PERLMODDIR)/YEP/Mirror/
	cp www/perl-lib/YEP/Parser/*.pm /$(DESTDIR)$(PERLMODDIR)/YEP/Parser/
	cp www/perl-lib/YEP/CLI.pm /$(DESTDIR)$(PERLMODDIR)/YEP/


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
	@mkdir -p $(NAME)-$(VERSION)/db
	@mkdir -p $(NAME)-$(VERSION)/doc
	@mkdir -p $(NAME)-$(VERSION)/script
	@mkdir -p $(NAME)-$(VERSION)/tests/YEP/Mirror
	@mkdir -p $(NAME)-$(VERSION)/tests/testdata/jobtest
	@mkdir -p $(NAME)-$(VERSION)/tests/testdata/rpmmdtest
	@mkdir -p $(NAME)-$(VERSION)/tests/testdata/regdatatest
	@mkdir -p $(NAME)-$(VERSION)/www/perl-lib/NU
	@mkdir -p $(NAME)-$(VERSION)/www/perl-lib/YEP/Mirror
	@mkdir -p $(NAME)-$(VERSION)/www/perl-lib/YEP/Parser

	@cp apache2/*.pl $(NAME)-$(VERSION)/apache2/
	@cp apache2/conf.d/*.conf $(NAME)-$(VERSION)/apache2/conf.d/
	@cp apache2/vhosts.d/*.conf $(NAME)-$(VERSION)/apache2/vhosts.d/
	@cp config/yep.conf.production $(NAME)-$(VERSION)/config/yep.conf
	@cp db/*.sql $(NAME)-$(VERSION)/db/
	@cp db/*.init $(NAME)-$(VERSION)/db/
	@cp db/README $(NAME)-$(VERSION)/db/
	@cp doc/* $(NAME)-$(VERSION)/doc/
	rm -f $(NAME)-$(VERSION)/doc/*~
	@cp tests/*.pl $(NAME)-$(VERSION)/tests/
	@cp tests/YEP/Mirror/*.pl $(NAME)-$(VERSION)/tests/YEP/Mirror/
	@cp -r tests/testdata/regdatatest/* $(NAME)-$(VERSION)/tests/testdata/regdatatest/
	@cp www/README $(NAME)-$(VERSION)/www/
	@cp script/yep-mirror.pl $(NAME)-$(VERSION)/script/
	@cp script/yepdb $(NAME)-$(VERSION)/script/
	@cp www/perl-lib/NU/*.pm $(NAME)-$(VERSION)/www/perl-lib/NU/
	@cp www/perl-lib/YEP/*.pm $(NAME)-$(VERSION)/www/perl-lib/YEP/
	@cp www/perl-lib/YEP/Mirror/*.pm $(NAME)-$(VERSION)/www/perl-lib/YEP/Mirror/
	@cp www/perl-lib/YEP/Parser/*.pm $(NAME)-$(VERSION)/www/perl-lib/YEP/Parser/
	@cp HACKING Makefile README COPYING $(NAME)-$(VERSION)/

	tar cfvj $(NAME)-$(VERSION).tar.bz2 $(NAME)-$(VERSION)/
