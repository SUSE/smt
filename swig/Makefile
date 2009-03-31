PERL        ?= perl
PERL_CC      = $(shell $(PERL) -MExtUtils::Embed -e ccopts)
PERL_LD      = $(shell $(PERL) -MExtUtils::Embed -e ldopts)
VENDOR_ARCH  = $(shell $(PERL) -MConfig -e 'print $$Config{installvendorarch};')

INCLUDES     = $(PERL_CC)

LIBS         = $(PERL_LD)

CXXFLAGS    += -Wno-unused -fPIC -DPIC $(RPM_OPT_FLAGS)
GCC          = gcc

MNAME    = GRP

all: $(MNAME).so

clean:
	rm -f *.o
	rm -f $(MNAME).so
	rm -f *.c
	rm -f $(MNAME).pm
	rm -fr auto Sys

$(MNAME).so: $(MNAME)_wrap.o
	$(GCC) -shared -o $(MNAME).so $< $(LDFLAGS) $(LIBS)
	@if test ! -d Sys; then mkdir -p Sys ; fi
	@if test ! -L Sys/$(MNAME).pm ; then \
		ln -s ../$(MNAME).pm Sys/$(MNAME).pm ; \
	fi
	@if test ! -d auto/Sys/$(MNAME) ; then \
		mkdir -p auto/Sys/$(MNAME) ; \
	fi
	@if test ! -L auto/Sys/$(MNAME)/$(MNAME).so ; then \
		ln -s ../../../$(MNAME).so auto/Sys/$(MNAME)/$(MNAME).so ; \
	fi

$(MNAME)_wrap.o: $(MNAME)_wrap.c
	$(GCC) $(CXXFLAGS) $(INCLUDES) -c $<

$(MNAME)_wrap.c: $(MNAME).i
	swig -perl5 -o $(MNAME)_wrap.c $<

install: $(MNAME).so
	mkdir -p $(DESTDIR)/$(VENDOR_ARCH)/auto/Sys/$(MNAME)
	mkdir -p $(DESTDIR)/$(VENDOR_ARCH)/Sys/
	install -m 644 $(MNAME).pm $(DESTDIR)/$(VENDOR_ARCH)/Sys/
	install -m 755 $(MNAME).so $(DESTDIR)/$(VENDOR_ARCH)/auto/Sys/$(MNAME)

dist:
	@mkdir -p ../$(NAME)-$(VERSION)/swig
	@cp Makefile ../$(NAME)-$(VERSION)/swig
	@cp $(MNAME).i ../$(NAME)-$(VERSION)/swig
