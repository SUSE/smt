#
# spec file for package smt (Version 1.0.18)
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


Name:           smt
BuildRequires:  apache2 apache2-mod_perl
Version:        1.0.19
Release:        0.<RELEASE4>
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
Requires:       openssl-certs
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

if [ ! -e "/var/lib/smt/RESCHEDULE_SYNC_DONE" ]; then
    /usr/lib/SMT/bin/reschedule-sync.sh
    if [ "$?" = "0" ]; then
        touch /var/lib/smt/RESCHEDULE_SYNC_DONE
    fi
fi

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
