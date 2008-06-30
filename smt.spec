#
# spec file for package smt (Version 1.0.4)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

# norootforbuild


Name:           smt
BuildRequires:  apache2 apache2-mod_perl
Version:        1.0.4
Release:        0.2
Requires:       perl = %{perl_version}
Requires:       apache2
Requires:       apache2-mod_perl
Requires:       perl-DBI
Requires:       perl-Crypt-SSLeay
Requires:       perl-Config-IniFiles
Requires:       perl-XML-Parser
Requires:       perl-XML-Writer
Requires:       perl-libwww-perl
Requires:       perl-IO-Zlib
Requires:       perl-URI
Requires:       perl-TimeDate
Requires:       perl-Text-ASCIITable
Requires:       perl-MIME-Lite
Requires:       limal-ca-mgm-perl
Requires:       perl-DBIx-Migration-Directories
Requires:       perl-DBIx-Transaction
Recommends:     mysql
Recommends:     perl-DBD-mysql
Recommends:     yast2-smt
PreReq:         %fillup_prereq apache2 apache2-mod_perl
AutoReqProv:    on
Group:          Productivity/Networking/Web/Proxy
License:        GPL v2 or later
Summary:        YaST Enterprise Proxy
Source:         %{name}-%{version}.tar.bz2
Source1:        sysconfig.apache2-smt
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
This package provide everything you need to get a local NU and
registration proxy.



Authors:
--------
    Authors:
    --------
        dmacvicar@suse.de
        mc@suse.de
        jdsn@suse.de
        locilka@suse.cz

%prep
%setup -n %{name}-%{version}
cp -p %{S:1} .
# ---------------------------------------------------------------------------

%build
mkdir man
cd script
for prog in smt*; do
    if pod2man --center=" " --release="%{version}-%{release}" --date="$(date)" $prog > $prog.$$$$ ; then
        perl -p -e 's/.if n .na/.\\\".if n .na/;' $prog.$$$$ > ../man/$prog.1;
    fi
    rm -f $prog.$$$$
done
cd -
#make test
# ---------------------------------------------------------------------------

%install
[ "$RPM_BUILD_ROOT" != "/" ] && [ -d $RPM_BUILD_ROOT ] && rm -rf $RPM_BUILD_ROOT
make DESTDIR=$RPM_BUILD_ROOT install
make DESTDIR=$RPM_BUILD_ROOT install_conf
mkdir -p $RPM_BUILD_ROOT/var/adm/fillup-templates/
install -m 644 sysconfig.apache2-smt   $RPM_BUILD_ROOT/var/adm/fillup-templates/
mkdir -p $RPM_BUILD_ROOT%{_mandir}/man1
cd man
for manp in smt*.1; do
    install -m 644 $manp    $RPM_BUILD_ROOT%{_mandir}/man1/$manp
done
# ---------------------------------------------------------------------------

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && [ -d $RPM_BUILD_ROOT ] && rm -rf $RPM_BUILD_ROOT

%preun
%stop_on_removal smt

%post
%{fillup_only -ans apache2 smt}
exit 0

%postun
%restart_on_update smt

%files
%defattr(-,root,root)
%dir %{perl_vendorlib}/SMT/
%dir %{perl_vendorlib}/SMT/Mirror
%dir %{perl_vendorlib}/SMT/Parser
%dir /etc/smt.d
%dir /srv/www/htdocs/repo/
%dir /srv/www/htdocs/testing/
%dir /srv/www/htdocs/testing/repo/
%dir /srv/www/perl-lib/NU/
%dir /srv/www/perl-lib/SMT/
%dir /usr/lib/SMT/
%dir /usr/lib/SMT/bin/
%dir %{_datadir}/schemas/
%dir %{_datadir}/schemas/smt
%config(noreplace) %attr(640, root, www)/etc/smt.conf
%config /etc/apache2/*.pl
%config /etc/smt.d/*.conf
%config /etc/smt.d/novell.com-smt
%config /etc/logrotate.d/smt
/etc/init.d/smt
/usr/sbin/rcsmt
%{perl_vendorlib}/SMT.pm
%{perl_vendorlib}/SMT/*.pm
%{perl_vendorlib}/SMT/Mirror/*.pm
%{perl_vendorlib}/SMT/Parser/*.pm
/srv/www/perl-lib/NU/*.pm
/srv/www/perl-lib/SMT/*.pm
/usr/sbin/smt-*
/usr/sbin/smt
/var/adm/fillup-templates/sysconfig.apache2-smt
/usr/lib/SMT/bin/*
%{_datadir}/schemas/smt/*
%doc %attr(644, root, root) %{_mandir}/man1/*
%doc README COPYING script/clientSetup4SMT.sh
%doc doc/High-Level-Architecture.odp doc/Registrationdata-NCC-YEP.odt
%doc doc/SMT-Database-Schema.odg doc/NCC-Client-Registration-via-YEP.odt
%doc doc/Server-Tuning.txt doc/SMT-Database-Schema.txt

%changelog
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
