#
# spec file for package smt
#
# Copyright (c) 2014 SUSE LINUX Products GmbH, Nuernberg, Germany.
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


Name:           smt
BuildRequires:  apache2
BuildRequires:  apache2-mod_perl
BuildRequires:  swig
Version:        3.0.0
Release:        0
Requires(pre):  apache2 apache2-mod_perl pwdutils
Requires:       createrepo
Requires:       gpg2
Requires:       perl-camgm
Requires:       logrotate
Requires:       ca-certificates
Requires:       perl = %{perl_version}
Requires:       perl-Config-IniFiles
Requires:       perl-DBI
Requires:       perl-Digest-SHA1
Requires:       perl-JSON
Requires:       perl-MIME-Lite
Requires:       perl-Text-ASCIITable
Requires:       perl-TimeDate
Requires:       perl-URI
Requires:       perl-WWW-Curl
Requires:       perl-XML-Parser
Requires:       perl-XML-Simple
Requires:       perl-XML-Writer
Requires:       perl-XML-XPath
Requires:       perl-gettext
Requires:       perl-libwww-perl
Recommends:     postgresql >= 9.2
Recommends:     postgresql-server >= 9.2
Recommends:     perl-DBD-Pg
Recommends:     yast2-smt
Conflicts:      slms-registration
Conflicts:      smt-client <= 0.0.14
Summary:        Subscription Management Tool
License:        GPL-2.0+
Group:          Productivity/Networking/Web/Proxy
Source0:         %{name}-%{version}.tar.bz2
Source1:        smt-rpmlintrc
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
# ---------------------------------------------------------------------------

%build
make
mkdir man
cd script

#processes *.pod twice, but this way they are processed after the real scripts and their data does not get rewritten
for prog in smt* smt*.pod; do
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
progfile="SMT::RESTService"
if pod2man --center=" " --release="%{version}-%{release}" --date="$(date)" www/perl-lib/SMT/RESTService.pm > www/perl-lib/SMT/RESTService.pm.$$$$ ; then
    perl -p -e 's/.if n .na/.\\\".if n .na/;' www/perl-lib/SMT/RESTService.pm.$$$$ > man/$progfile.3pm;
fi
rm -f www/perl-lib/SMT/RESTService.pm.$$$$
#make test
# ---------------------------------------------------------------------------

%install

/usr/sbin/useradd -r -g www -s /bin/false -c "User for SMT" -d /var/lib/empty smt 2> /dev/null || :

make DESTDIR=$RPM_BUILD_ROOT DOCDIR=%{_docdir} install
make DESTDIR=$RPM_BUILD_ROOT install_conf

mkdir -p $RPM_BUILD_ROOT%{_mandir}/man1
mkdir -p $RPM_BUILD_ROOT%{_mandir}/man3
cd man
for manp in smt*.1; do
    install -m 644 $manp    $RPM_BUILD_ROOT%{_mandir}/man1/$manp
done
for manp in *.3pm; do
    install -m 644 $manp    $RPM_BUILD_ROOT%{_mandir}/man3/$manp
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

%post
sysconf_addword /etc/sysconfig/apache2 APACHE_MODULES perl
sysconf_addword /etc/sysconfig/apache2 APACHE_SERVER_FLAGS SSL


%files
%defattr(-,root,root)
%dir %{perl_vendorlib}/SMT/
%dir %{perl_vendorlib}/SMT/Mirror
%dir %{perl_vendorlib}/SMT/Parser
%dir %{perl_vendorlib}/SMT/Rest
%dir %{perl_vendorarch}/Sys
%dir %{perl_vendorarch}/auto/Sys/
%dir %{perl_vendorarch}/auto/Sys/GRP
%dir /etc/smt.d
%dir /etc/slp.reg.d
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
%config /etc/apache2/conf.d/*.conf
%config /etc/apache2/vhosts.d/*.conf
%config /etc/smt.d/*.conf
%config /etc/slp.reg.d/smt.reg
%config /etc/cron.d/novell.com-smt
%config /etc/logrotate.d/smt
%config /etc/tmpfiles.d/smt.conf
%{perl_vendorlib}/SMT.pm
%{perl_vendorlib}/SMT/*.pm
%{perl_vendorlib}/SMT/Mirror/*.pm
%{perl_vendorlib}/SMT/Parser/*.pm
%{perl_vendorlib}/SMT/Rest/*.pm
%{perl_vendorarch}/Sys/*.pm
%{perl_vendorarch}/auto/Sys/GRP/*.so
/srv/www/perl-lib/NU/*.pm
/srv/www/perl-lib/SMT/*.pm
/srv/www/perl-lib/SMT/Client/*.pm
/usr/sbin/smt-*
/usr/sbin/smt
/usr/lib/SMT/bin/*
/usr/bin/smt*
/usr/lib/systemd/system/smt.target
/srv/www/htdocs/repo/tools/*
%{_datadir}/schemas/smt/*
%doc %attr(644, root, root) %{_mandir}/man3/*
%doc %attr(644, root, root) %{_mandir}/man1/*
%exclude %{_mandir}/man1/smt-support.1.gz
%doc %{_docdir}/smt/*
%exclude /etc/apache2/conf.d/smt_support.conf
%exclude /srv/www/perl-lib/SMT/Support.pm
%exclude /usr/sbin/smt-support

%files -n res-signingkeys
%defattr(-,root,root)
%dir %attr(755, smt, www)/srv/www/htdocs/repo/keys
/srv/www/htdocs/repo/keys/res-signingkeys.key

%files support
%defattr(-,root,root)
/usr/sbin/smt-support
/srv/www/perl-lib/SMT/Support.pm
%config /etc/apache2/conf.d/smt_support.conf
%dir %attr(775, smt, www)/var/spool/smt-support
%doc %attr(644, root, root) %{_mandir}/man1/smt-support.1.gz

%changelog
