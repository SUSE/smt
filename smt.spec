#
# spec file for package smt (Version 0.4.0)
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
Version:        0.4.0
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
Requires:	limal-ca-mgm-perl
Requires:       perl-DBIx-Migration-Directories
Requires:	perl-DBIx-Transaction
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
%config(noreplace) %attr(640, wwwrun, root)/etc/smt.conf
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

%attr(644, root, root) %{_mandir}/man1/*
%doc README COPYING script/clientSetup4SMT.sh

%changelog
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
