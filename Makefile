NAME          = smt
VERSION       = 3.0.0
DESTDIR       = /
PERL         ?= perl
PERLMODDIR    = $(shell $(PERL) -MConfig -e 'print $$Config{installvendorlib};')
TEMPF         = $(shell mktemp)
DOCDIR        = /usr/share/doc/packages

all:
	make -C swig

install_all: install install_conf

install_conf:
	mkdir -p $(DESTDIR)/etc/
	install -m 640 config/smt.conf $(DESTDIR)/etc/
	mkdir -p $(DESTDIR)/etc/init.d/

install:
	mkdir -p $(DESTDIR)/usr/sbin/
	mkdir -p $(DESTDIR)/usr/bin/
	mkdir -p $(DESTDIR)/etc/apache2/conf.d
	mkdir -p $(DESTDIR)/etc/apache2/vhosts.d
	mkdir -p $(DESTDIR)/etc/cron.d/
	mkdir -p $(DESTDIR)/etc/smt.d/
	mkdir -p $(DESTDIR)/etc/logrotate.d/
	mkdir -p $(DESTDIR)/etc/slp.reg.d/
	mkdir -p $(DESTDIR)/srv/www/htdocs/repo/tools
	mkdir -p $(DESTDIR)/srv/www/htdocs/repo/keys
	mkdir -p $(DESTDIR)/srv/www/htdocs/repo/testing
	mkdir -p $(DESTDIR)/srv/www/htdocs/repo/full
	mkdir -p $(DESTDIR)/srv/www/perl-lib/NU
	mkdir -p $(DESTDIR)/srv/www/perl-lib/SMT
	mkdir -p $(DESTDIR)/srv/www/perl-lib/SMT/Client
	mkdir -p $(DESTDIR)$(PERLMODDIR)/SMT/Mirror
	mkdir -p $(DESTDIR)$(PERLMODDIR)/SMT/Parser
	mkdir -p $(DESTDIR)$(PERLMODDIR)/SMT/Rest
	mkdir -p $(DESTDIR)/usr/share/schemas/smt
	mkdir -p $(DESTDIR)/usr/share/schemas/smt/Pg
	mkdir -p $(DESTDIR)/usr/lib/SMT/bin/
	mkdir -p $(DESTDIR)/usr/lib/systemd/system/
	mkdir -p $(DESTDIR)$(DOCDIR)/smt
	install -m 644 apache2/smt-mod_perl-startup.pl $(DESTDIR)/etc/apache2/
	install -m 644 apache2/conf.d/*.conf $(DESTDIR)/etc/apache2/conf.d/
	install -m 644 apache2/vhosts.d/*.conf $(DESTDIR)/etc/apache2/vhosts.d/
	install -m 755 script/smt $(DESTDIR)/usr/sbin/
	install -m 755 script/smt-* $(DESTDIR)/usr/sbin/
	install -m 644 www/perl-lib/NU/*.pm $(DESTDIR)/srv/www/perl-lib/NU/
	install -m 644 www/perl-lib/SMT/Registration.pm $(DESTDIR)/srv/www/perl-lib/SMT/
	install -m 644 www/perl-lib/SMT/Support.pm $(DESTDIR)/srv/www/perl-lib/SMT/
	install -m 644 www/perl-lib/SMT/Utils.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/Mirror/*.pm /$(DESTDIR)$(PERLMODDIR)/SMT/Mirror/
	install -m 644 www/perl-lib/SMT/Parser/*.pm /$(DESTDIR)$(PERLMODDIR)/SMT/Parser/
	install -m 644 www/perl-lib/SMT/Client/*.pm /$(DESTDIR)/srv/www/perl-lib/SMT/Client/
	install -m 644 www/perl-lib/SMT/CLI.pm /$(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/Curl.pm /$(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/DB.pm /$(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT.pm $(DESTDIR)$(PERLMODDIR)
	install -m 644 www/perl-lib/SMT/Repositories.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/Client.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/Package.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/Patch.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/PatchRef.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/Product.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/SCC*.pm $(DESTDIR)$(PERLMODDIR)/SMT/
	install -m 644 www/perl-lib/SMT/RESTService.pm $(DESTDIR)/srv/www/perl-lib/SMT/
	install -m 644 www/perl-lib/SMT/RESTInfo.pm $(DESTDIR)/srv/www/perl-lib/SMT/
	install -m 644 www/perl-lib/SMT/Rest/*.pm $(DESTDIR)$(PERLMODDIR)/SMT/Rest/
	install -m 644 www/perl-lib/SMT/ConnectAPI.pm $(DESTDIR)/srv/www/perl-lib/SMT/
	cd db/schemas; \
	find Pg/ \
                  -type d -exec install -m755 -d $(DESTDIR)/usr/share/schemas/smt/\{\} \; \
                  -o \
                  \( -type f -exec install -m644 \{\} $(DESTDIR)/usr/share/schemas/smt/\{\} \; \)
	install -m 755 config/smt.target $(DESTDIR)/usr/lib/systemd/system/
	install -m 755 config/smt.reg $(DESTDIR)/etc/slp.reg.d/
	install -m 755 db/smt-setup-db $(DESTDIR)/usr/lib/SMT/bin/
	install -m 755 db/smt-sql $(DESTDIR)/usr/bin/
	install -m 755 db/smt-schema-upgrade $(DESTDIR)/usr/bin/
	install -m 755 script/changeSMTUserPermissions.sh $(DESTDIR)/usr/lib/SMT/bin/
	install -m 755 script/clientSetup4SMT.sh $(DESTDIR)/srv/www/htdocs/repo/tools/
	install -m 644 www/repo/res-signingkeys.key $(DESTDIR)/srv/www/htdocs/repo/keys/
	install -m 644 cron/novell.com-smt $(DESTDIR)/etc/cron.d/
	install -m 644 cron/smt-cron.conf $(DESTDIR)/etc/smt.d/
	install -m 755 cron/smt-daily $(DESTDIR)/usr/lib/SMT/bin/
	install -m 755 cron/smt-run-jobqueue-cleanup $(DESTDIR)/usr/lib/SMT/bin/
	install -m 755 cron/smt-jobqueue-cleanup $(DESTDIR)/usr/lib/SMT/bin/
	install -m 755 cron/smt-gen-report $(DESTDIR)/usr/lib/SMT/bin/
	install -m 755 cron/smt-repeated-register $(DESTDIR)/usr/lib/SMT/bin/
	install -m 644 logrotate/smt $(DESTDIR)/etc/logrotate.d/

	install -m 644 README $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 COPYING $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 doc/High-Level-Architecture.odp $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 doc/Registrationdata-NCC-YEP.odt $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 doc/SMT-Database-Schema.odg $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 doc/NCC-Client-Registration-via-YEP.odt $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 doc/Server-Tuning.txt $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 doc/SMT-Database-Schema.txt $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 doc/SMT-REST-API.txt $(DESTDIR)$(DOCDIR)/smt/
	install -m 644 doc/README-SCC $(DESTDIR)$(DOCDIR)/smt/
	make -C swig $@

	mkdir -p $(DESTDIR)/var/spool/smt-support
	chown smt:www $(DESTDIR)/var/spool/smt-support || echo "Set ownership manually: chown smt:www $(DESTDIR)/var/spool/smt-support"
	chmod 775 $(DESTDIR)/var/spool/smt-support || echo "Set permission manually: chmod 775 $(DESTDIR)/var/spool/smt-support"

test: clean
	cd tests; perl tests.pl && cd -

clean:
	find . -name "*~" -print0 | xargs -0 rm -f
	rm -rf $(NAME)-*/
	rm -f $(NAME)-*.tar.bz2
	rm -f package/$(NAME)-*.tar.bz2
	make -C swig $@

maintainer-clean: clean
	make -C yast maintainer-clean
	rm -f yast/*.ami
	rm -f yast/configure yast/configure.in
	find yast/ -name "Makefile.in" -print0 | xargs -0 rm -f
	rm -f yast/config.guess
	rm -f yast/config.sub
	rm -f yast/Makefile.am*
	rm -f yast/missing
	rm -f yast/aclocal.m4
	rm -f yast/install-sh

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
	@mkdir -p $(NAME)-$(VERSION)/tests/testdata/rpmmdtest
	@mkdir -p $(NAME)-$(VERSION)/www
	@mkdir -p $(NAME)-$(VERSION)/logrotate

	@cp apache2/*.pl $(NAME)-$(VERSION)/apache2/
	@cp apache2/conf.d/*.conf $(NAME)-$(VERSION)/apache2/conf.d/
	@cp apache2/vhosts.d/*.conf $(NAME)-$(VERSION)/apache2/vhosts.d/
	@cp config/smt.conf.production $(NAME)-$(VERSION)/config/smt.conf
	@cp config/smt.target $(NAME)-$(VERSION)/config/
	@cp config/smt.reg $(NAME)-$(VERSION)/config/
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
	@cp doc/SMT-REST-API.txt $(NAME)-$(VERSION)/doc/
	@cp doc/README-SCC $(NAME)-$(VERSION)/doc/

	@cp tests/*.pl $(NAME)-$(VERSION)/tests/
	@cp tests/SMT/Mirror/*.pl $(NAME)-$(VERSION)/tests/SMT/Mirror/
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

	tar cfvj $(NAME)-$(VERSION).tar.bz2 $(NAME)-$(VERSION)/

pot:
	find www/ -name "*.pm" > sourcefiles
	find script/ -maxdepth 1 -name "smt*" >> sourcefiles
	xgettext --default-domain=smt --directory=. --keyword=__ -o smt.pot --files-from sourcefiles
	rm -f sourcefiles

package: dist
	mv $(NAME)-$(VERSION).tar.bz2 package/

