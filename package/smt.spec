#
# spec file for package smt (Version 1.1.7)
#
# Copyright (c) 2008,2009 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

# norootforbuild


Name:           smt
BuildRequires:  apache2 apache2-mod_perl swig
Version:        1.1.7
Release:        0.2
Requires:       perl = %{perl_version}
Requires:       perl-DBI
Requires:       perl-Crypt-SSLeay
Requires:       perl-Config-IniFiles
Requires:       perl-XML-Parser
Requires:       perl-XML-Writer
Requires:       perl-libwww-perl
Requires:       perl-URI
Requires:       perl-TimeDate
Requires:       perl-Text-ASCIITable
Requires:       perl-MIME-Lite
Requires:       perl-Digest-SHA1
Requires:       limal-ca-mgm-perl
Requires:       perl-DBIx-Migration-Directories
Requires:       perl-DBIx-Transaction
Requires:       logrotate
Requires:       suseRegister
Requires:       htmldoc
Requires:       createrepo
Requires:       gpg2
Recommends:     mysql
Recommends:     perl-DBD-mysql
Recommends:     yast2-smt
PreReq:         %fillup_prereq apache2 apache2-mod_perl pwdutils
AutoReqProv:    on
Group:          Productivity/Networking/Web/Proxy
License:        GPL v2 or later
Summary:        Subscription Management Tool
Source:         %{name}-%{version}.tar.bz2
Source1:        sysconfig.apache2-smt
Source2:        smt-rpmlintrc
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
This package provides everything you need to get a local NU and
registration proxy.



Authors:
--------
    Authors:
    --------
        dmacvicar@suse.de
        jdsn@suse.de
        jkupec@suse.cz
        jsrain@suse.cz
        locilka@suse.cz
        mc@suse.de
        rhafer@suse.de
        tgoettlicher@suse.de

%package -n res-signingkeys
License:        GPL v2 or later
Summary:        Signing Key for RES
Group:          Productivity/Networking/Web/Proxy
Prereq:         smt = %version

%description -n res-signingkeys
This package contains the signing key for RES.

%package support
License:        GPL v2 or later
Summary:        SMT support proxy
Group:          Productivity/Networking/Web/Proxy
Prereq:         smt = %version

%description support
This package contains proxy for support data


%prep
%setup -n %{name}-%{version}
cp -p %{S:1} .
# ---------------------------------------------------------------------------

%build
make
mkdir man
cd script
for prog in smt* smt*.pod; do #processes *.pod twice, but this way they are processed after the real scripts and thir data does not get rewritten
    progfile=`echo "$prog" | sed 's/\(.*\)\.pod/\1/'`
    if pod2man --center=" " --release="%{version}-%{release}" --date="$(date)" $prog > $prog.$$$$ ; then
        perl -p -e 's/.if n .na/.\\\".if n .na/;' $prog.$$$$ > ../man/$progfile.1;
    fi
    rm -f $prog.$$$$
done
rm smt*.pod #don't package .pod-files
cd -
#make test
# ---------------------------------------------------------------------------

%install

/usr/sbin/useradd -r -g www -s /bin/false -c "User for SMT" -d /var/lib/empty smt 2> /dev/null || :

make DESTDIR=$RPM_BUILD_ROOT DOCDIR=%{_docdir} install
make DESTDIR=$RPM_BUILD_ROOT install_conf

mkdir -p $RPM_BUILD_ROOT/var/adm/fillup-templates/
install -m 644 sysconfig.apache2-smt   $RPM_BUILD_ROOT/var/adm/fillup-templates/
mkdir -p $RPM_BUILD_ROOT%{_mandir}/man1
cd man
for manp in smt*.1; do
    install -m 644 $manp    $RPM_BUILD_ROOT%{_mandir}/man1/$manp
done
mkdir -p $RPM_BUILD_ROOT/var/run/smt
mkdir -p $RPM_BUILD_ROOT/var/log/smt
mkdir -p $RPM_BUILD_ROOT%{_docdir}/smt/
mkdir -p $RPM_BUILD_ROOT/var/lib/smt

ln -s /srv/www/htdocs/repo/tools/clientSetup4SMT.sh $RPM_BUILD_ROOT%{_docdir}/smt/clientSetup4SMT.sh

# ---------------------------------------------------------------------------

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && [ -d $RPM_BUILD_ROOT ] && rm -rf $RPM_BUILD_ROOT

%pre
if ! usr/bin/getent passwd smt >/dev/null; then
  usr/sbin/useradd -r -g www -s /bin/false -c "User for SMT" -d /var/lib/smt smt 2> /dev/null || :
fi

%preun
%stop_on_removal smt

%post
%{fillup_only -ans apache2 smt}
exit 0

%postun
%restart_on_update smt
%insserv_cleanup

%files
%defattr(-,root,root)
%dir %{perl_vendorlib}/SMT/
%dir %{perl_vendorlib}/SMT/Mirror
%dir %{perl_vendorlib}/SMT/Parser
%dir %{perl_vendorarch}/Sys
%dir %{perl_vendorarch}/auto/Sys/
%dir %{perl_vendorarch}/auto/Sys/GRP
%dir /etc/smt.d
%dir %attr(755, smt, www)/srv/www/htdocs/repo/
%dir %attr(755, smt, www)/srv/www/htdocs/repo/tools
%dir %attr(755, smt, www)/srv/www/htdocs/repo/keys
%dir %attr(755, smt, www)/srv/www/htdocs/repo/testing
%dir %attr(755, smt, www)/srv/www/htdocs/repo/full
%dir /srv/www/perl-lib/NU/
%dir /srv/www/perl-lib/SMT/
%dir /usr/lib/SMT/
%dir /usr/lib/SMT/bin/
%dir %{_datadir}/schemas/
%dir %{_datadir}/schemas/smt
%dir %{_docdir}/smt/
%dir %attr(755, smt, www)/var/run/smt
%dir %attr(755, smt, www)/var/log/smt
%dir %attr(755, smt, www)/var/lib/smt
%config(noreplace) %attr(640, root, www)/etc/smt.conf
%config /etc/apache2/*.pl
%config /etc/smt.d/*.conf
%exclude /etc/smt.d/smt_support.conf
%config /etc/smt.d/novell.com-smt
%config /etc/logrotate.d/smt
/etc/init.d/smt
/usr/sbin/rcsmt
%{perl_vendorlib}/SMT.pm
%{perl_vendorlib}/SMT/*.pm
%{perl_vendorlib}/SMT/Mirror/*.pm
%{perl_vendorlib}/SMT/Parser/*.pm
%{perl_vendorarch}/Sys/*.pm
%{perl_vendorarch}/auto/Sys/GRP/*.so
/srv/www/perl-lib/NU/*.pm
/srv/www/perl-lib/SMT/*.pm
%exclude /srv/www/perl-lib/SMT/Support.pm
/usr/sbin/smt-*
%exclude /usr/sbin/smt-support
/usr/sbin/smt
/var/adm/fillup-templates/sysconfig.apache2-smt
/usr/lib/SMT/bin/*
/srv/www/htdocs/repo/tools/*
%{_datadir}/schemas/smt/*
%doc %attr(644, root, root) %{_mandir}/man1/*
%exclude %{_mandir}/man1/smt-support.1.gz
%doc %{_docdir}/smt/*



%files -n res-signingkeys
%defattr(-,root,root)
%dir %attr(755, smt, www)/srv/www/htdocs/repo/keys
/srv/www/htdocs/repo/keys/res-signingkeys.key

%files support
%defattr(-,root,root)
/usr/sbin/smt-support
/srv/www/perl-lib/SMT/Support.pm
%config /etc/smt.d/smt_support.conf
%dir %attr(775, smt, www)/var/spool/smt-support
%doc %attr(644, root, root) %{_mandir}/man1/smt-support.1.gz

%changelog
* Thu Dec 04 2008 - mc@suse.de
- version 1.0.8
  * do not suppress forbidden error when trying to mirror
  non-entitled catalogs with smt-mirror-sle9. (bnc#445607)
  * improve speed when copying metadata (bnc#430808)
  * parse virttype from host element
  * improve clientSetup4SMT to detect several possible places
  where the certificate has to be stored.
  * do not try to put a certificate to zmd/trusted-certs/ if zmd
  is not installed.
* Wed Oct 29 2008 - mc@suse.de
- version 1.0.7
  * create database with charset latin1 (bnc#430146)
  * proxy urls should not have a trailing / (bnc#433508)
  * support for older yum repository format
  * do not require repomd.xml.key if repomd.xml.asc exists
  (bnc#439154)
* Thu Sep 11 2008 - mc@suse.de
- version 1.0.6
  * create todir if it does not exists.(bnc#406328)
  * create extra mirror directory if it does not exists. (bnc#406304)
  * write logmessage if repoindex return a directory which is marked
  for mirroring but is currently not available. (bnc#416737)
  * store repoindex.xml to a tmp directory (may fix bnc#416737)
  * add option --regcert to clientSetup4SMT.sh (bnc#421079)
  * fix local SMT Virtual Machine Report (bnc#413757)
  * catch error on head request (bnc#425387)
* Tue Jul 01 2008 - mc@suse.de
- version 1.0.5
  * smt-ncc-sync: honor --help
  * fix texts in report (bnc#405148, bnc#393776)
* Mon Jun 30 2008 - mc@suse.de
- version 1.0.4
  * get client IP if no hostname was send and store it in the
  client table (bnc#403695)
  * smt-report: warnings should not drop alerts. (bnc#403703)
* Tue Jun 24 2008 - mc@suse.de
- version 1.0.3
  * catch SSL errors on download and provide nice error message
  instead of a perl backtrace. (bnc#401607)
  * add check for root user to clientSetup4SMT.sh
  * fix not running apache after rcsmt start (bnc#403104)
* Wed Jun 18 2008 - mc@suse.de
- version 1.0.2
  * smt-setup-custom-catalog: enhance help text and man page:
  add info about how to find out the Catalog ID (bnc#400501)
  * close filehandles if we do not need them anymore (bnc#399260)
* Fri Jun 13 2008 - mc@suse.de
- version 1.0.1
  * fix "unlimited" handling in the report summary table
  (bnc#398875)
  * adding a DISCLAIMER to the bottom of a report
  * show also unused expired subscriptions in report
  to match NCC report (bnc#398120)
  * change column titles to improve the report
  (first step to fix bnc#398130)
  * fix product detection (bnc#398817)
  * add verbose mode to list-registrations, which shows also
  the subscriptions where this client is assigned to, if
  NCC registration is enabled. (bnc#398166)
* Mon Jun 09 2008 - mc@suse.de
- version 1.0.0
  * fix some per warnings
  * set a UserAgent timeout
  * manually adding a header to an ASCIITable to speed up
  rendering (bnc#396702)
  * reduce max register requests in one bulkop to 15.
  * small fixes in man pages and help texts
  * fix return, in case of no catalog were removed
  (part of bnc#397100)
  * move proxy settings into a seperate function
  * implement own proxy variables in smt.conf (bnc#397369)
  * allow to mirror not signed repositories (bnc#397118)
  * fix some problems with --dryrun
  * fix some problems with verify and deepverify
  * read global proxy settings inside of cron scripts
  (bnc#398589)
* Mon Jun 02 2008 - mc@suse.de
- version 0.9.7
  * fix wrong SQL statement with NODCOUNT = -1 (bnc#396291)
  * fix csv headlines
* Wed May 28 2008 - dmacvicar@suse.de
- version 0.9.6
  * changes on man pages, texts and command
  line options
  * (bnc#393776)
  * (bnc#393778)
  * (bnc#390085)
  * (bnc#393075)
* Wed May 21 2008 - mc@suse.de
- version 0.9.5
  * changes on man pages and texts.
* Tue May 20 2008 - mc@suse.de
- version 0.9.4
  * mirror-sle9: add timeout options to wget (bnc#390240)
  * mirror-sle9: use same filehandle for OUT and ERR (bnc#390240)
  * new man page drafts
  * fix some messages (bnc#391439)
  * implement proxy authentication support (bnc#392495)
  * follow redirects when flagging mirrorable catalogs (bnc#392509)
  * show productIDs in list-products output (bnc#391997)
* Tue May 13 2008 - mc@suse.de
- version 0.9.3
  * do not send a NU service if we do not have a catalog for the
  client (maybe fix bnc#388406)
* Fri May 09 2008 - mc@suse.de
- version 0.9.2
  * fix incorrect time stamps on mirrored files (bnc#388227)
  * change logging in SMT::Registration and NU::RepoIndex
  * use different logging function
  * no informational logging by default(only errors)
  * write Site ID and SMT ID into the report
  * second draft for the legend
  * fix help of smt scripts (bnc#387402)
  * mark some documentation to be installed
  * mark man-pages as %%doc
  * add --host <smt hostname> option to clientSetup4SMT.sh
  to generate the URL based on the provided hostname
* Thu May 08 2008 - mc@suse.de
- version 0.9.1
  * create logfiles with 600 permissions
  * rotate if logfile size is above 4MB
  * show an error if no product were found during
  smt catalogs -enable-by-prod
  * add hint to smt catalogs --help how to find
  valid product names
  * fix column name in list-products. A product
  has an architecture, no target
  * calculate locally used Subscriptions directly via
  PRODUCT_CLASS columns in Subscriptions and Products table.
  * parse <product-class> from NCC result
  * rename smt-mirror-sles9 to smt-mirror-sle9 (bnc#387405)
  - Database version 0.09
    - drop ProductSubscriptions table
    - rename PRODGROUP to PRODUCT_CLASS in Subscriptions table
* Tue May 06 2008 - mc@suse.de
- version 0.9.0
  * fix smt ncc-sync does not enable zypp catalogs (bnc#384363)
  * sync with ncc before generate report
  * add parameter --nonccsync to disable ncc sync during
  report generation
  * create only reports we want to show
  * add smt-gen-report
  * remove report from smt-daily
  * get commandline options from smt-cron.conf
  The admin has now the possibility to change the parameters
  * add smt-gen-report to cron
  * rename YEP => SMT in smt help
  * fixes to be able to run smt-ncc-sync --todir <dir> without
  database
  * fix parsing of <consumed>
  * If start-date and/or end-date of a subscription is 0, this
  subscriptions expires never
  * parse SUBID from listsubscriptions call
  * generate PRODGROUP during listsubscriptions
  * modify report to use SUBID instead of REGCODE and PRODGROUP
  instead of SUBNAME
  * strip | character from path before using it for XML::Parser
  (bnc#383759)
  * add check of localdir() (bnc#383759)
  - Database version 0.08
    - Subscription table:
    - SUBSTARTDATE and SUBENDATE can be NULL
    - Add SUBID as primary key
    - add PRODGROUP
    - modify ProductSubscriptions and ClientSubscriptions table
  to use SUBID as reference to Subscriptions
* Mon Apr 28 2008 - mc@suse.de
- version 0.8.0
  * fix disable catalogs if only the target is provided
  * set HTTPS_CA_DIR and enable certificate checking
  * set NCCREGERROR if registration at NCC failed
  * do not register clients at NCC which registration failed before
  * add --reseterror parameter to smt-register
  * add alert to report, with the number of failed NCC registrations
* Fri Apr 25 2008 - mc@suse.de
- version 0.7.1
  * send ostarget and ostarget-bak with de-register call
  * implement mirror src rpms enable/disable (bnc#383191)
  * fix update Registration table
  * register maximal 25 clients in one bulkop call
  if we need to register more, put them in a seperate call
* Fri Apr 25 2008 - mc@suse.de
- version 0.7.0
  * delete no longer existing NCC data from Products, Catalogs,
  ProductCatalogs and Targets table.
* Fri Apr 25 2008 - mc@suse.de
- version 0.6.1
  * fix database setup
* Thu Apr 24 2008 - mc@suse.de
- version 0.6.0
  * add CONSUMED column to Subscription table
  * change report behaviour to use the CONSUMED value
  from NCC if client registration is enabled and
  create a local report only if client registration
  is disabled.
  * Enable full NCC syncronization
  * bugfixes
  * remove temporary data from database
* Tue Apr 22 2008 - mc@suse.de
- version 0.5.0
  * be sure that apache and (if required) mysql is running if
  'rcsmt start' is called(bnc#378701)
  * add mirror script for sles9 repositories
  * changing ownership of smt.conf from 'wwwrun,root' to 'root,www'
  * implementation of bulk operation for registration
  * implement --dryrun (bnc#380598)
  * fix name of backup suseRegister.conf file in clientSetup4SMT.sh
  * rework report module to use consumed value from NCC to
  show company wide subscription status
* Fri Apr 11 2008 - mc@suse.de
- version 0.4.1
  * only enable selected catalogs - fix cancel (bnc#378302)
  * test correct error variable to make ncc-sync not fail silently
  (bnc#367678)
  * prepare man pages
  * fix counting of recipient addresses
* Fri Apr 11 2008 - mc@suse.de
- version 0.4.0
  * default database user is now smt
  * smt-catalog: fix parameter handling
  * initial setup of max_connections for mysqldb
  * adding mail and csv support to smt-report
* Mon Apr 07 2008 - mc@suse.de
- version 0.3.2
  * quote username in smt-db
  * set correct owner of smt.conf in smt-db setup and smt-db cpw
* Fri Apr 04 2008 - mc@suse.de
- version 0.3.1
  * fix ostarget-bak handling
  * implement client setup script
  * randomize start of register cronjob
  * enhance smt-db to create the database and to change
  the password for the smt user.
  * adding generic function to render reports
* Mon Mar 31 2008 - mc@suse.de
- version 0.3.0
  * add workflow for database migration
  * filter catalogs returned by repoindex.xml by architecture
  * add cronjobs
  * add init script for smt
  * some protocol changes in NCC communication
  * adding logrotate configuration to rotate smt logs
  * mirror only MIRRORABLE catalogs of type NU
  * add certificate check to report module
  * copy certificate in init script
  * improve lock function
  * implement 'enable catalogs by product'
  * enhance list-products with a catalog status.
  * several bugfixes
* Fri Mar 07 2008 - mc@suse.de
- version 0.2.1
  * use NULL as default for NCCREGDATE
  * use no default for SUBSTARTDATE and SUBENDDATE
  * registration return a error if [LOCAL] url is empty
  * skip catalogs where we do not have correct urls
  * try to make all statements database independent by using
  DBI bind_param method for Date and Time columns
  * some small bugfixes
* Thu Mar 06 2008 - mc@suse.de
- version 0.2.0
  * add more test data
  * add target to clients table
  * add new paramter to smt.conf (forwardRegistration, nccEmail)
  * change default permissions of smt.conf to 640, wwwrun, root
  * support for listsubscriptions
  * changed output of listregistrations
  * update report module
* Wed Feb 27 2008 - mc@suse.de
- rename yep => smt
  * version 0.1.0
  * strip whitespaces behind the url
  * remove unused clients
* Thu Feb 21 2008 - mc@suse.de
- version 0.0.6
  * implement logfile support for mirror, register and  ncc-sync
  * Add "MirrorAll" parameter to yep.conf
  * implement the hardlink feature
  * implement report module
* Fri Feb 08 2008 - mc@suse.de
- version 0.0.5
  * Add database tables SubscriptionStatus and Clients
  * drop table ProductDependencies
  * lock support for yep-mirror and other client tools
  * replace catalog-mirror-flags and list-catalogs with
  simply yep-catalogs
  * implement first versions of client tools for NCC
  connection (yep-register, yep-delete-registration)
  * bugfixes
* Fri Feb 01 2008 - mc@suse.de
- version 0.0.4
  * add Parser for RpmMd, NU, RegData
  * speed-up verify and add deepverify option to yep-mirror
  * adding more tools
  * various bugfixes
  * support for custom catalogs
  * support for running YEP in isolated networks
  * switch to mysql as default database
  * download patch and delta RPMs
  * yep-mirror download the meta data into a temporary directory
  first, to keep the repository valid during mirror operation.
* Mon Jan 21 2008 - mc@suse.de
- version 0.0.3
  * rename some vars in yep.conf
  * use XML::Writer module everywhere
  * RepoIndex.pm return no-cache header
  * find and use ostarget during registration
  * restart apache on update
  * move client tools to /usr/sbin
* Thu Jan 17 2008 - mc@suse.de
- version 0.0.2
  * initial registration server
  * support SSL
  * support testing enviroment
* Fri Jan 11 2008 - mc@suse.de
- version 0.0.1 - initial version
