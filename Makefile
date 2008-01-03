


install:
	@cp apache2/mod_perl-startup.pl /etc/apache2/
	@cp apache2/conf.d/*.conf /etc/apache2/conf.d/
	@mkdir -p /srv/www/perl-lib/NU
	@mkdir -p /srv/www/perl-lib/YEP/Mirror
	@cp www/perl-lib/yep-mirror.pl /srv/www/perl-lib/
	@cp www/perl-lib/NU/*.pm /srv/www/perl-lib/NU/
	@cp www/perl-lib/YEP/*.pm /srv/www/perl-lib/YEP/
	@cp www/perl-lib/YEP/Mirror/*.pm /srv/www/perl-lib/YEP/Mirror/
	@cp config/yep.conf /etc/

	cd db; sqlite3 -init setupdb.init /srv/www/yep.db '.exit'; cd -

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
	@echo " "
	@echo "Finaly start the web server with 'rcapache2 start'"
	@echo "==========================================================="
