# Makefile.am for yep/src

yncludedir = @yncludedir@/yep

client_DATA = \
	yep.ycp

ynclude_DATA = \
	dialogs.ycp \
	helps.ycp \
	complex.ycp \
	wizard.ycp

desktop_DATA = $(wildcard *.desktop)

module_DATA = $(wildcard YEP*.ycp)

# create a symlink for local build, #145327
yep:
	ln -sf . $@
ycpchook = yep

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common
