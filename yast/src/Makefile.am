# Makefile.am for smt/src

yncludedir = @yncludedir@/smt

client_DATA = \
	smt.ycp

ynclude_DATA = \
	dialogs.ycp \
	helps.ycp \
	complex.ycp \
	wizard.ycp

desktop_DATA = $(wildcard *.desktop)

module_DATA = $(wildcard SMT*.ycp)

# create a symlink for local build, #145327
smt:
	ln -sf . $@
ycpchook = smt

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common
