NAME          = smt-client
VERSION       = 0.0.16
DESTDIR       = /
PERL         ?= perl
PERLMODDIR    = $(shell $(PERL) -MConfig -e 'print $$Config{installvendorlib};')
TEMPF         = $(shell mktemp)
DOCDIR        = /usr/share/doc/packages

all:
	echo that is all

install_all: install 

#install_conf:
#	mkdir -p $(DESTDIR)/etc/
#	install -m 640 config/smt.conf $(DESTDIR)/etc/
#	mkdir -p $(DESTDIR)/etc/init.d/

install:
	mkdir -p $(DESTDIR)/usr/sbin/
	mkdir -p $(DESTDIR)/etc/logrotate.d/
	mkdir -p $(DESTDIR)$(PERLMODDIR)/SMT/Agent
	mkdir -p $(DESTDIR)/usr/lib/SMT/bin/
	mkdir -p $(DESTDIR)/usr/lib/SMT/bin/job/
	mkdir -p $(DESTDIR)$(DOCDIR)/$(NAME)/
	install -m 755 script/smt-* $(DESTDIR)/usr/sbin/
	install -m 644 perl-lib/SMT/Agent/*.pm /$(DESTDIR)$(PERLMODDIR)/SMT/Agent/
	install -m 755 script/processjob $(DESTDIR)/usr/lib/SMT/bin/
	install -m 755 script/softwarepush $(DESTDIR)/usr/lib/SMT/bin/job
	install -m 755 script/patchstatus $(DESTDIR)/usr/lib/SMT/bin/job
	install -m 755 script/execute $(DESTDIR)/usr/lib/SMT/bin/job
	install -m 755 script/eject $(DESTDIR)/usr/lib/SMT/bin/job
	install -m 755 script/update $(DESTDIR)/usr/lib/SMT/bin/job
	install -m 755 script/reboot $(DESTDIR)/usr/lib/SMT/bin/job
	install -m 755 script/wait $(DESTDIR)/usr/lib/SMT/bin/job
	install -m 644 logrotate/smt-client $(DESTDIR)/etc/logrotate.d/

	install -m 644 README $(DESTDIR)$(DOCDIR)/$(NAME)/
	install -m 644 COPYING $(DESTDIR)$(DOCDIR)/$(NAME)/

test: clean
	cd tests; perl tests.pl && cd -

clean:
	find . -name "*~" -print0 | xargs -0 rm -f
	rm -rf tests/testdata/rpmmdtest/*
	rm -rf $(NAME)-*/
	rm -f $(NAME)-*.tar.bz2
	rm -f package/$(NAME)-*.tar.bz2

dist: clean
	rm -rf $(NAME)-$(VERSION)/
#	@mkdir -p $(NAME)-$(VERSION)/config
	@mkdir -p $(NAME)-$(VERSION)/cron
	@mkdir -p $(NAME)-$(VERSION)/script
	@mkdir -p $(NAME)-$(VERSION)/logrotate

#	@cp config/smt.conf.production $(NAME)-$(VERSION)/config/smt.conf
#	@cp config/rc.smt $(NAME)-$(VERSION)/config/
#	@cp cron/smt-* $(NAME)-$(VERSION)/cron/
#	@cp cron/novell.com-smt $(NAME)-$(VERSION)/cron/
	@cp README $(NAME)-$(VERSION)/
	@cp COPYING $(NAME)-$(VERSION)/
	@cp script/* $(NAME)-$(VERSION)/script/
	@cp logrotate/smt-client $(NAME)-$(VERSION)/logrotate/
	find perl-lib -name ".svn" -prune -o \
                \( \
                  \( -type d -exec install -m755 -d $(NAME)-$(VERSION)/\{\} \; \) \
                  -o \
                  \( -type f -exec install -m644 \{\} $(NAME)-$(VERSION)/\{\} \; \) \
                \)
#	make -C swig NAME=$(NAME) VERSION=$(VERSION) $@
	@cp Makefile $(NAME)-$(VERSION)/
#	@rm $(NAME)-$(VERSION)/www/README

	tar cfvj $(NAME)-$(VERSION).tar.bz2 $(NAME)-$(VERSION)/

#pot:
#	find www/ -name "*.pm" > sourcefiles
#	find script/ -maxdepth 1 -name "smt*" >> sourcefiles
#	xgettext --default-domain=smt --directory=. --keyword=__ -o smt.pot --files-from sourcefiles
#	rm -f sourcefiles

package: dist
	mv $(NAME)-$(VERSION).tar.bz2 package/

