#
# spec file for package smt-client (
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


Name:           smt-client
#BuildRequires:  apache2 apache2-mod_perl swig
Version:        0.0.1
Release:        0.1
Requires:       perl = %{perl_version}
Requires:       perl-Crypt-SSLeay
Requires:       perl-Config-IniFiles
Requires:       perl-XML-Parser
Requires:       perl-XML-Writer
Requires:       logrotate
PreReq:         %fillup_prereq apache2 apache2-mod_perl pwdutils
AutoReqProv:    on
Group:          Productivity/Networking/Web/Proxy
License:        GPL v2 or later
Summary:        Client for Subscription Management Tool
Source:         %{name}-%{version}.tar.bz2
Source1:        sysconfig.smt-client
Source2:        smt-client-rpmlintrc
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
This package provides a client for Subscription Management Tool

Authors:
--------
jdsn@suse.de
tgoettlicher@suse.de


%prep
%setup -n %{name}-%{version}
cp -p %{S:1} .
# ---------------------------------------------------------------------------

%build
make
#mkdir man
#cd script
#for prog in smt* smt*.pod; do #processes *.pod twice, but this way they are processed after the real scripts and thir data does not get rewritten
#    progfile=`echo "$prog" | sed 's/\(.*\)\.pod/\1/'`
#    if pod2man --center=" " --release="%{version}-%{release}" --date="$(date)" $prog > $prog.$$$$ ; then
#        perl -p -e 's/.if n .na/.\\\".if n .na/;' $prog.$$$$ > ../man/$progfile.1;
#    fi
#    rm -f $prog.$$$$
#done
#rm smt*.pod #don't package .pod-files
#cd -

%install

make DESTDIR=$RPM_BUILD_ROOT DOCDIR=%{_docdir} install
#make DESTDIR=$RPM_BUILD_ROOT install_conf

mkdir -p $RPM_BUILD_ROOT/var/adm/fillup-templates/
install -m 644 sysconfig.smt-client  $RPM_BUILD_ROOT/var/adm/fillup-templates/
mkdir -p $RPM_BUILD_ROOT/var/run/smt
mkdir -p $RPM_BUILD_ROOT/var/log/smt-client
mkdir -p $RPM_BUILD_ROOT%{_docdir}/smt/
mkdir -p $RPM_BUILD_ROOT/var/lib/smt

# ---------------------------------------------------------------------------

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && [ -d $RPM_BUILD_ROOT ] && rm -rf $RPM_BUILD_ROOT

%post 
%{fillup_only}
exit 0

%files
%defattr(-,root,root)
%dir %{perl_vendorlib}/SMT/Agent
%{perl_vendorlib}/SMT/Agent/*.pm
/usr/sbin/smt-agent
%dir /usr/lib/SMT/bin/job/
%dir /usr/lib/SMT/bin/job/*
%dir /usr/lib/SMT
%dir /usr/lib/SMT/bin
%dir /usr/lib/perl5/vendor_perl/5.10.0/SMT
/usr/lib/SMT/bin/processjob
/var/adm/fillup-templates/sysconfig.smt-client

%changelog
