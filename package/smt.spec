#
# spec file for package smt
#
# Copyright (c) 2015 SUSE LINUX GmbH, Nuernberg, Germany.
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
Version:        3.0.1
Release:        0
Summary:        Subscription Management Tool
License:        GPL-2.0+
Group:          Productivity/Networking/Web/Proxy
Source0:        %{name}-%{version}.tar.bz2
Source1:        smt-rpmlintrc
BuildRequires:  apache2
BuildRequires:  apache2-mod_perl
BuildRequires:  swig
Requires:       ca-certificates
Requires:       createrepo
Requires:       gpg2
Requires:       logrotate
Requires:       perl = %{perl_version}
Requires:       perl(Config::IniFiles)
Requires:       perl(DBI)
Requires:       perl(Date::Parse)
Requires:       perl(DateTime)
Requires:       perl(Digest::SHA1)
Requires:       perl(JSON)
Requires:       perl(LWP)
Requires:       perl(Locale::gettext)
Requires:       perl(MIME::Lite)
Requires:       perl(Text::ASCIITable)
Requires:       perl(URI)
Requires:       perl(WWW::Curl)
Requires:       perl(XML::Parser)
Requires:       perl(XML::Simple)
Requires:       perl(XML::Writer)
Requires:       perl(XML::XPath)
Requires:       perl(solv)
Requires(pre):  apache2
Requires(pre):  apache2-mod_perl
Requires(pre):  pwdutils
Recommends:     mariadb
Recommends:     perl(DBD::mysql)
Recommends:     yast2-smt
Conflicts:      slms-registration
Conflicts:      smt-client <= 0.0.14
BuildRoot:      %{_tmppath}/%{name}-%{version}-build

%description
This package provide everything you need to get a local NU and
registration proxy.

%package -n res-signingkeys
Summary:        Signing Key for RES
Group:          Productivity/Security
# FIXME: use proper Requires(pre/post/preun/...)
PreReq:         smt = %{version}

%description -n res-signingkeys
This package contain the signing key for RES.

%package support
Summary:        SMT support proxy
Group:          Productivity/Networking/Web/Proxy
# FIXME: use proper Requires(pre/post/preun/...)
PreReq:         smt = %{version}

%description support
This package contains proxy for Novell Support Link

%prep
%setup -q
# ---------------------------------------------------------------------------

%build
make %{?_smp_mflags}
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
# delete test rpms, they are interfering with clamav
rm -rf tests/testdata
# ---------------------------------------------------------------------------

%install
make DESTDIR=%{buildroot} DOCDIR=%{_docdir} install
make DESTDIR=%{buildroot} install_conf

mkdir -p %{buildroot}%{_mandir}/man1
mkdir -p %{buildroot}%{_mandir}/man3
cd man
for manp in smt*.1; do
    install -m 644 $manp    %{buildroot}%{_mandir}/man1/$manp
done
for manp in *.3pm; do
    install -m 644 $manp    %{buildroot}%{_mandir}/man3/$manp
done

mkdir -p %{buildroot}%{_localstatedir}/log/smt/schema-upgrade
mkdir -p %{buildroot}%{_docdir}/smt/
mkdir -p %{buildroot}%{_localstatedir}/lib/smt

ln -s /srv/www/htdocs/repo/tools/clientSetup4SMT.sh %{buildroot}%{_docdir}/smt/clientSetup4SMT.sh

# ---------------------------------------------------------------------------

%pre
%{_bindir}/getent passwd smt >/dev/null || %{_sbindir}/useradd -r -g www -s %{_bindir}/false -c "User for SMT" -d %{_localstatedir}/lib/smt smt
%service_add_pre smt-schema-upgrade.service
%service_add_pre smt.target

%post
sysconf_addword %{_sysconfdir}/sysconfig/apache2 APACHE_MODULES perl
sysconf_addword %{_sysconfdir}/sysconfig/apache2 APACHE_SERVER_FLAGS SSL
usr/bin/systemd-tmpfiles --create %{_tmpfilesdir}/%{name}.conf || :
%service_add_post smt-schema-upgrade.service
%service_add_post smt.target

if [ "$1" = "2" ]; then
    rm -f %{_localstatedir}/adm/update-messages/%{name}-%{version}-%{release}
    # check if there are MyISAM tables, if yes add note about migrating them to InnoDB
    if ! %{_bindir}/smt-schema-upgrade --check-engine; then
        cat > %{_localstatedir}/adm/update-messages/%{name}-%{version}-%{release} <<EOT
SMT database must be migrated to InnoDB engine.

Call /usr/bin/smt-schema-upgrade to upgrade DB.
Migration will also start automatically by smt-schema-upgrade service when smt.target is started.
If you are not using systemd's smt.target, please call /usr/bin/smt-schema-upgrade manually.

Please review your database settings to reflect this change.
(see https://mariadb.com/kb/en/mariadb/converting-tables-from-myisam-to-innodb/#non-index-issues)

EOT
    fi
    # check if there is need to schema migration
    if ! %{_bindir}/smt-schema-upgrade --check-schema; then
        cat >> %{_localstatedir}/adm/update-messages/%{name}-%{version}-%{release} <<EOT
SMT database schema must be migrated to new schema version.

Call /usr/bin/smt-schema-upgrade to upgrade DB.
Migration will also start automatically by smt-schema-upgrade service when smt.target is started.
If you are not using systemd's smt.target, please call /usr/bin/smt-schema-upgrade manually.

EOT
    fi
fi

%preun
%service_del_preun smt-schema-upgrade.service
%service_del_preun smt.target

# no postun service handling, we don't want them to be restarted on upgrade

%files
%defattr(-,root,root)
%dir %{perl_vendorlib}/SMT/
%dir %{perl_vendorlib}/SMT/Job
%dir %{perl_vendorlib}/SMT/Utils
%dir %{perl_vendorlib}/SMT/Mirror
%dir %{perl_vendorlib}/SMT/Parser
%dir %{perl_vendorlib}/SMT/Rest
%dir %{perl_vendorarch}/Sys
%dir %{perl_vendorarch}/auto/Sys/
%dir %{perl_vendorarch}/auto/Sys/GRP
%dir %{_sysconfdir}/smt.d
%dir %{_sysconfdir}/slp.reg.d
%dir %attr(755, smt, www)/srv/www/htdocs/repo/
%dir %attr(755, smt, www)/srv/www/htdocs/repo/tools
%dir %attr(755, smt, www)/srv/www/htdocs/repo/keys
%dir %attr(755, smt, www)/srv/www/htdocs/repo/testing
%dir %attr(755, smt, www)/srv/www/htdocs/repo/full
%dir /srv/www/perl-lib/NU/
%dir /srv/www/perl-lib/SMT/
%dir /srv/www/perl-lib/SMT/Client
%dir %{_libexecdir}/SMT/
%dir %{_libexecdir}/SMT/bin/
%dir %{_datadir}/schemas/
%dir %{_datadir}/schemas/smt
%dir %{_docdir}/smt/
%dir %attr(755, smt, www)%{_localstatedir}/log/smt
%dir %attr(755, smt, www)%{_localstatedir}/log/smt/schema-upgrade
%dir %attr(755, smt, www)%{_localstatedir}/lib/smt
%config(noreplace) %attr(640, root, www)%{_sysconfdir}/smt.conf
%config %{_sysconfdir}/apache2/*.pl
%config %{_sysconfdir}/apache2/conf.d/*.conf
%config %{_sysconfdir}/apache2/vhosts.d/*.conf
%config %{_sysconfdir}/smt.d/*.conf
%config %{_sysconfdir}/slp.reg.d/smt.reg
%{_tmpfilesdir}/smt.conf
%exclude %{_sysconfdir}/apache2/conf.d/smt_support.conf
%config %{_sysconfdir}/cron.d/novell.com-smt
%config %{_sysconfdir}/logrotate.d/smt
%{perl_vendorlib}/SMT.pm
%{perl_vendorlib}/SMT/*.pm
%{perl_vendorlib}/SMT/Job/*.pm
%{perl_vendorlib}/SMT/Utils/*.pm
%{perl_vendorlib}/SMT/Mirror/*.pm
%{perl_vendorlib}/SMT/Parser/*.pm
%{perl_vendorlib}/SMT/Rest/*.pm
%{perl_vendorarch}/Sys/*.pm
%{perl_vendorarch}/auto/Sys/GRP/*.so
/srv/www/perl-lib/NU/*.pm
/srv/www/perl-lib/SMT/*.pm
/srv/www/perl-lib/SMT/Client/*.pm
%exclude /srv/www/perl-lib/SMT/Support.pm
%{_sbindir}/smt-*
%exclude %{_sbindir}/smt-support
%{_sbindir}/smt
%{_libexecdir}/SMT/bin/*
%{_bindir}/smt*
%{_libexecdir}/systemd/system/smt.target
%{_libexecdir}/systemd/system/smt-schema-upgrade.service
/srv/www/htdocs/repo/tools/*
%{_datadir}/schemas/smt/*
%{_bindir}/smt-*
%doc %attr(644, root, root) %{_mandir}/man3/*
%doc %attr(644, root, root) %{_mandir}/man1/*
%exclude %{_mandir}/man1/smt-support.1.gz
%doc %{_docdir}/smt/*

%files -n res-signingkeys
%defattr(-,root,root)
%dir %attr(755, smt, www)/srv/www/htdocs/repo/keys
/srv/www/htdocs/repo/keys/res-signingkeys.key

%files support
%defattr(-,root,root)
%{_sbindir}/smt-support
/srv/www/perl-lib/SMT/Support.pm
%config %{_sysconfdir}/apache2/conf.d/smt_support.conf
%dir %attr(775, smt, www)%{_localstatedir}/spool/smt-support
%doc %attr(644, root, root) %{_mandir}/man1/smt-support.1.gz

%changelog
