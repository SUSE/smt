#
# spec file for package smt (Version 1.1.20)
#
# Copyright (c) 2010 SUSE LINUX Products GmbH, Nuernberg, Germany.
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
Version:        1.1.21
Release:        0.<RELEASE6>
Requires:       perl = %{perl_version}
Requires:       perl-DBI
Requires:       perl-Crypt-SSLeay
Requires:       perl-Config-IniFiles
Requires:       perl-gettext
Requires:       perl-XML-Simple
Requires:       perl-XML-Parser
Requires:       perl-XML-Writer
Requires:       perl-XML-XPath
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
Requires:       satsolver-tools perl-satsolver
Recommends:     mysql
Recommends:     perl-DBD-mysql
Recommends:     yast2-smt
Conflicts:      slms-registration
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

%package -n res-signingkeys
License:        GPL v2 or later
Summary:        Signing Key for RES
Group:          Productivity/Security
PreReq:         smt = %version

%description -n res-signingkeys
This package contain the signing key for RES.



Authors:
--------
    Authors:
    --------
        dmacvicar@suse.de
        mc@suse.de
        jdsn@suse.de
        locilka@suse.cz

%package support
License:        GPL v2 or later
Summary:        SMT support proxy
Group:          Productivity/Networking/Web/Proxy
PreReq:         smt = %version

%description support
This package contains proxy for Novell Support Link



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
# BNC #511168 (smt-catalogs is a symlink to smt-repos)
ln -s smt-repos.1 ../man/smt-catalogs.1
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
%dir /srv/www/perl-lib/SMT/Client
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
/srv/www/perl-lib/SMT/Client/*.pm
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
