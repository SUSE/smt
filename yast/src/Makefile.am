# Makefile.am for smt/src

yncludedir = @yncludedir@/smt

client_DATA = \
	clients/smt.rb \
	clients/smt-server.rb \
	clients/smt-wizard.rb

ynclude_DATA = \
	include/smt/dialogs.rb \
	include/smt/helps.rb \
	include/smt/complex.rb \
	include/smt/wizard.rb

control_DATA = \
	control/smt_control.xml

ybin_SCRIPTS = scripts/regsrv-check-creds

desktop_DATA = $(wildcard desktop/*.desktop)

module_DATA = $(wildcard modules/SMT*.rb)

# create a symlink for local build, #145327
#smt:
#	ln -sf . $@
#ycpchook = smt

controldir = $(yast2dir)/control

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(desktop_DATA) $(control_DATA) $(ybin_SCRIPTS)

include $(top_srcdir)/Makefile.am.common
