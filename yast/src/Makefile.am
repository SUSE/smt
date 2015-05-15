# Makefile.am for smt/src

yncludedir = @yncludedir@/smt

client_DATA = \
	clients/smt.ycp \
	clients/smt-server.ycp \
	clients/inst_smt.ycp \
	clients/smt_generate_new_credentials.ycp

ynclude_DATA = \
	include/smt/dialogs.ycp \
	include/smt/helps.ycp \
	include/smt/complex.ycp \
	include/smt/wizard.ycp

control_DATA = \
	control/smt_control.xml

ybin_SCRIPTS = scripts/regsrv-check-creds

desktop_DATA = $(wildcard desktop/*.desktop)

module_DATA = $(wildcard modules/SMT*.ycp)

# create a symlink for local build, #145327
#smt:
#	ln -sf . $@
#ycpchook = smt

controldir = $(yast2dir)/control

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(desktop_DATA) $(control_DATA) $(ybin_SCRIPTS)

include $(top_srcdir)/Makefile.am.common
