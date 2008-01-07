#
# spec file for package yep (Version 0.0.1)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://www.suse.de/feedback/
#

# norootforbuild

Name:         yep
BuildRequires: sqlite apache2 apache2-mod_perl
Version:      0.0.1
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

Autoreqprov:  on
Group:        Productivity/Networking/Web/Proxy
License:      Artistic License
Summary:      YaST Enterprise Proxy
Source:       %{name}-%{version}.tar.bz2
BuildRoot:    %{_tmppath}/%{name}-%{version}-build

%description
This package provide everything you need to get a YaST Enterprise Proxy



Authors:
--------
    dmacvicar@suse.de
    mc@suse.de
    jdsn@suse.de

%prep
%setup -n %{name}-%{version}
# ---------------------------------------------------------------------------

%build
# ---------------------------------------------------------------------------

%install
[ "$RPM_BUILD_ROOT" != "/" ] && [ -d $RPM_BUILD_ROOT ] && rm -rf $RPM_BUILD_ROOT
make DESTDIR=$RPM_BUILD_ROOT install

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && [ -d $RPM_BUILD_ROOT ] && rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%dir %{perl_vendorlib}/YEP/
%dir %{perl_vendorlib}/YEP/Mirror
%{perl_vendorlib}/YEP/*.pm
%{perl_vendorlib}/YEP/Mirror/*.pm
%dir /srv/www/htdocs/repo/
%dir /srv/www/htdocs/YUM/
%dir /srv/www/perl-lib/NU/
/srv/www/perl-lib/NU/*.pm
/srv/www/yep.db
%config(noreplace) /etc/yep.conf
%config /etc/apache2/*.pl
%config /etc/apache2/conf.d/*.conf
/usr/bin/yep-mirror.pl

#%doc MANIFEST README ChangeLog

%changelog 
