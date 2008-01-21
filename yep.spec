#
# spec file for package yep (Version 0.0.3)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

# norootforbuild

Name:           yep
BuildRequires:  apache2 apache2-mod_perl perl-Crypt-SSLeay perl-DBD-SQLite sqlite yast2 yast2-devtools
BuildRequires:  perl-Config-IniFiles perl-IO-Zlib perl-TimeDate perl-URI perl-XML-Parser perl-libwww-perl
Version:        0.0.3
Release:        0.2
Requires:       perl = %{perl_version}
Requires:       apache2
Requires:       apache2-mod_perl
Requires:       sqlite
Requires:       perl-DBI
Requires:       perl-DBD-SQLite
Requires:       perl-Crypt-SSLeay
Requires:       perl-Config-IniFiles
Requires:       perl-XML-Parser
Requires:       perl-XML-Writer
Requires:       perl-libwww-perl
Requires:       perl-IO-Zlib
Requires:       perl-URI
Requires:       perl-TimeDate
PreReq:         %fillup_prereq apache2 apache2-mod_perl
Requires:       yast2
# For testing entered cedentials in YaST
Requires:       grep
Requires:       curl
AutoReqProv:    on
Group:          Productivity/Networking/Web/Proxy
License:        GPL v2 or later
Summary:        YaST Enterprise Proxy
Source:         %{name}-%{version}.tar.bz2
Source1:        sysconfig.apache2-yep
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
make DESTDIR=$RPM_BUILD_ROOT install_all
mkdir -p $RPM_BUILD_ROOT/var/adm/fillup-templates/
install -m 644 sysconfig.apache2-yep   $RPM_BUILD_ROOT/var/adm/fillup-templates/
# ---------------------------------------------------------------------------

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && [ -d $RPM_BUILD_ROOT ] && rm -rf $RPM_BUILD_ROOT

%post
%{fillup_only -ans apache2 yep}
exit 0

%postun
%restart_on_update apache2

%files
%defattr(-,root,root)
%dir %{perl_vendorlib}/YEP/
%dir %{perl_vendorlib}/YEP/Mirror
%dir %{perl_vendorlib}/YEP/Parser
%dir /var/lib/YEP
%dir %attr(-, wwwrun, www)/var/lib/YEP/db
%dir /srv/www/htdocs/repo/
%dir /srv/www/htdocs/testing/
%dir /srv/www/htdocs/testing/repo/
%dir /srv/www/perl-lib/NU/
%dir /srv/www/perl-lib/YEP/
%config(noreplace) /etc/yep.conf
%config /etc/apache2/*.pl
%config /etc/apache2/conf.d/*.conf
%config /etc/apache2/vhosts.d/*.conf
%{perl_vendorlib}/YEP/*.pm
%{perl_vendorlib}/YEP/Mirror/*.pm
%{perl_vendorlib}/YEP/Parser/*.pm
/srv/www/perl-lib/NU/*.pm
/srv/www/perl-lib/YEP/*.pm
%attr(-, wwwrun, www)/var/lib/YEP/db/yep.db
/usr/sbin/yep-*
/usr/sbin/yep
/var/adm/fillup-templates/sysconfig.apache2-yep
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
