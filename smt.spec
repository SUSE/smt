#
# spec file for package smt (Version 0.2.1)
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
Version:        0.2.1
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
#make test
# ---------------------------------------------------------------------------

%install
[ "$RPM_BUILD_ROOT" != "/" ] && [ -d $RPM_BUILD_ROOT ] && rm -rf $RPM_BUILD_ROOT
make DESTDIR=$RPM_BUILD_ROOT install
make DESTDIR=$RPM_BUILD_ROOT install_conf
mkdir -p $RPM_BUILD_ROOT/var/lib/SMT/db
install -m 644 db/*.sql $RPM_BUILD_ROOT/var/lib/SMT/db/
install -m 755 db/setup_mysql.sh $RPM_BUILD_ROOT/var/lib/SMT/db/
mkdir -p $RPM_BUILD_ROOT/var/adm/fillup-templates/
install -m 644 sysconfig.apache2-smt   $RPM_BUILD_ROOT/var/adm/fillup-templates/

# create apache config links
mkdir -p $RPM_BUILD_ROOT/etc/apache2/conf.d/
mkdir -p $RPM_BUILD_ROOT/etc/apache2/vhosts.d/

ln -s /etc/smt.d/nu_server.conf $RPM_BUILD_ROOT/etc/apache2/conf.d/nu_server.conf
ln -s /etc/smt.d/smt_mod_perl.conf $RPM_BUILD_ROOT/etc/apache2/conf.d/smt_mod_perl.conf
ln -s /etc/smt.d/vhost-ssl.conf $RPM_BUILD_ROOT/etc/apache2/vhosts.d/vhost-ssl.conf

# ---------------------------------------------------------------------------

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && [ -d $RPM_BUILD_ROOT ] && rm -rf $RPM_BUILD_ROOT

%post
%{fillup_only -ans apache2 smt}
exit 0

%postun
%restart_on_update apache2

%files
%defattr(-,root,root)
%dir %{perl_vendorlib}/SMT/
%dir %{perl_vendorlib}/SMT/Mirror
%dir %{perl_vendorlib}/SMT/Parser
%dir /etc/smt.d
%dir /var/lib/SMT
%dir /var/lib/SMT/db
%dir /srv/www/htdocs/repo/
%dir /srv/www/htdocs/testing/
%dir /srv/www/htdocs/testing/repo/
%dir /srv/www/perl-lib/NU/
%dir /srv/www/perl-lib/SMT/
%config(noreplace) %attr(640, wwwrun, root)/etc/smt.conf
%config /etc/apache2/*.pl
%config /etc/smt.d/*.conf
/etc/apache2/conf.d/*.conf
/etc/apache2/vhosts.d/*.conf
%{perl_vendorlib}/SMT/*.pm
%{perl_vendorlib}/SMT/Mirror/*.pm
%{perl_vendorlib}/SMT/Parser/*.pm
/srv/www/perl-lib/NU/*.pm
/srv/www/perl-lib/SMT/*.pm
/usr/sbin/smt-*
/usr/sbin/smt
/var/lib/SMT/db/*
/var/adm/fillup-templates/sysconfig.apache2-smt
%dir %{_datadir}/schemas/smt
%{_datadir}/schemas/smt/*

%doc README COPYING 

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
