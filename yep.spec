#
# spec file for package yep (Version 0.0.2)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://www.suse.de/feedback/
#

# norootforbuild

Name:         yep
BuildRequires: sqlite apache2 apache2-mod_perl perl-Crypt-SSLeay perl-DBD-SQLite yast2 yast2-devtools
BuildRequires: perl-Config-IniFiles perl-XML-Parser perl-libwww-perl perl-IO-Zlib perl-URI perl-TimeDate
Version:      0.0.2
Release:      0
Requires:     perl = %{perl_version}
Requires:     apache2
Requires:     apache2-mod_perl
Requires:     sqlite
Requires:     perl-DBI
Requires:     perl-DBD-SQLite
Requires:     perl-Crypt-SSLeay
Requires:     perl-Config-IniFiles
Requires:     perl-XML-Parser
Requires:     perl-XML-Writer
Requires:     perl-libwww-perl
Requires:     perl-IO-Zlib
Requires:     perl-URI
Requires:     perl-TimeDate
PreReq:       %insserv_prereq %fillup_prereq

Requires:     yast2
# For testing entered cedentials in YaST
Requires:     grep
Requires:     curl

Autoreqprov:  on
Group:        Productivity/Networking/Web/Proxy
License:      Artistic License
Summary:      YaST Enterprise Proxy
Source:       %{name}-%{version}.tar.bz2
Source1:      sysconfig.apache2-yep
BuildRoot:    %{_tmppath}/%{name}-%{version}-build

%description
This package provide everything you need to get a local NU and
registration proxy.



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


%files
%defattr(-,root,root)
%dir %{perl_vendorlib}/YEP/
%dir %{perl_vendorlib}/YEP/Mirror
%dir /var/lib/YEP
%dir %attr(-, wwwrun, www)/var/lib/YEP/db
%dir /srv/www/htdocs/repo/
%dir /srv/www/perl-lib/NU/
%dir /srv/www/perl-lib/YEP/
%config(noreplace) /etc/yep.conf
%config /etc/apache2/*.pl
%config /etc/apache2/conf.d/*.conf
%config /etc/apache2/vhosts.d/*.conf

%{perl_vendorlib}/YEP/*.pm
%{perl_vendorlib}/YEP/Mirror/*.pm

/srv/www/perl-lib/NU/*.pm
/srv/www/perl-lib/YEP/*.pm

%attr(-, wwwrun, www)/var/lib/YEP/db/yep.db

/usr/bin/yep-mirror.pl
/usr/bin/yepdb

/var/adm/fillup-templates/sysconfig.apache2-yep

%doc README COPYING 


%changelog 
