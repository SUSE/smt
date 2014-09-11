#
# spec file for package smt-client
#
# Copyright (c) 2012 SUSE LINUX Products GmbH, Nuernberg, Germany.
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


Name:           smt-client
Version:        1.0.2
Release:        0.1
Requires:       perl = %{perl_version}
Requires:       perl-XML-XPath
Requires:       perl-XML-Parser
Requires:       perl-XML-Writer
Requires:       perl-IO-Socket-SSL
Requires:       perl-base
Requires:       perl-libwww-perl
Requires:       perl-LWP-Protocol-https
Requires:       logrotate
Requires:       cron
Requires:       zypper >= 1.3.14
Requires:       libzypp >= 6.36.0
Conflicts:      smt <= 1.1.21
PreReq:         %fillup_prereq
AutoReqProv:    on
Group:          Productivity/Networking/Web/Proxy
License:        GPL-2.0+
Summary:        Subscription Management Tool
Source:         %{name}-%{version}.tar.bz2
Source1:        sysconfig.smt-client
Source2:        smt-client-rpmlintrc
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
URL:            https://github.com/SUSE/smt

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
make

%install

make DESTDIR=$RPM_BUILD_ROOT DOCDIR=%{_docdir} install

mkdir -p $RPM_BUILD_ROOT/var/adm/fillup-templates/
install -m 644 sysconfig.smt-client  $RPM_BUILD_ROOT/var/adm/fillup-templates/

# touching the ghost
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}/cron.d/
touch $RPM_BUILD_ROOT/%{_sysconfdir}/cron.d/novell.com-smt-client

# ---------------------------------------------------------------------------

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && [ -d $RPM_BUILD_ROOT ] && rm -rf $RPM_BUILD_ROOT

%post
if [ ! -s /etc/cron.d/novell.com-smt-client ]; then
    minute=`expr $RANDOM % 60`
    echo "$minute */3 * * * root /usr/sbin/smt-agent" > %{_sysconfdir}/cron.d/novell.com-smt-client
fi
%{fillup_only}
exit 0

%files
%defattr(-,root,root)
%dir %{perl_vendorlib}/SMT
%dir %{perl_vendorlib}/SMT/Agent
%{perl_vendorlib}/SMT/Agent/*.pm
/usr/sbin/smt-agent
%dir /usr/lib/SMT
%dir /usr/lib/SMT/bin
%dir /usr/lib/SMT/bin/job
/usr/lib/SMT/bin/job/*
/usr/lib/SMT/bin/processjob
/var/adm/fillup-templates/sysconfig.smt-client
%ghost %{_sysconfdir}/cron.d/novell.com-smt-client
%config /etc/logrotate.d/smt-client
%ghost %dir /run/smtclient
%dir %{_docdir}/smt-client
%{_docdir}/smt-client/*

%changelog
