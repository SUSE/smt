NAME         = yep
VERSION      = 0.0.1
DESTDIR      = /
PERL        ?= perl
PERLMODDIR   = $(shell $(PERL) -MConfig -e 'print $$Config{installvendorlib};')

install_all: install install_conf install_db
	@echo "==========================================================="
	@echo "Append 'perl' to APACHE_MODULES in /etc/sysconfig/apache2 ."
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
	@echo "Finaly start the web server with 'rcapache2 start'"
	@echo "==========================================================="

install_db:
	mkdir -p $(DESTDIR)/var/lib/YaST2/
	cd db; sqlite3 -init setupdb.init $(DESTDIR)/var/lib/YaST2/yep.db '.exit'; cd -

install_conf:
	mkdir -p $(DESTDIR)/etc/
	cp config/yep.conf $(DESTDIR)/etc/

install:
	mkdir -p $(DESTDIR)/usr/bin/
	mkdir -p $(DESTDIR)/etc/apache2/conf.d/
	mkdir -p $(DESTDIR)/srv/www/htdocs/repo
	mkdir -p $(DESTDIR)/srv/www/htdocs/YUM
	mkdir -p $(DESTDIR)/srv/www/perl-lib/NU
	mkdir -p $(DESTDIR)$(PERLMODDIR)/YEP/Mirror
	cp apache2/mod_perl-startup.pl $(DESTDIR)/etc/apache2/
	cp apache2/conf.d/*.conf $(DESTDIR)/etc/apache2/conf.d/
	cp script/yep-mirror.pl $(DESTDIR)/usr/bin/
	cp script/yepdb $(DESTDIR)/usr/bin/
	chmod 0755 $(DESTDIR)/usr/bin/yep-mirror.pl
	chmod 0755 $(DESTDIR)/usr/bin/yepdb
	cp www/perl-lib/NU/*.pm $(DESTDIR)/srv/www/perl-lib/NU/
	cp www/perl-lib/YEP/*.pm $(DESTDIR)$(PERLMODDIR)/YEP/
	cp www/perl-lib/YEP/Mirror/*.pm /$(DESTDIR)$(PERLMODDIR)/YEP/Mirror/


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

	@cp apache2/*.pl $(NAME)-$(VERSION)/apache2/
	@cp apache2/conf.d/*.conf $(NAME)-$(VERSION)/apache2/conf.d/
	@cp config/*.conf $(NAME)-$(VERSION)/config/
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
	@cp HACKING Makefile $(NAME)-$(VERSION)/

	tar cfvj $(NAME)-$(VERSION).tar.bz2 $(NAME)-$(VERSION)/
