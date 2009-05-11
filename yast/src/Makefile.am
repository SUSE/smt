# Makefile.am for smt/src

yncludedir = @yncludedir@/smt

client_DATA = \
	smt.ycp \
	smt-server.ycp \
	inst_smt.ycp \
	smt_generate_new_credentials.ycp

ynclude_DATA = \
	dialogs.ycp \
	helps.ycp \
	complex.ycp \
	wizard.ycp

control_DATA = \
	smt_control.xml

desktop_DATA = $(wildcard *.desktop)

module_DATA = $(wildcard SMT*.ycp)

# create a symlink for local build, #145327
smt:
	ln -sf . $@
ycpchook = smt

controldir = $(yast2dir)/control

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(desktop_DATA) $(control_DATA)

include $(top_srcdir)/Makefile.am.common
