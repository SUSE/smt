This document describes setting up SMT server with a mirror of repositories in a
virtual environment and registering a client against it.

This document was written for SLES version 12.2.

# Prerequisites

Sufficient disk space is required for mirroring, the exact amount depends on the
the repositories selected for mirroring.
The recommended amount of free space for mandatory SLES 12.2 repositories is
10 GB.

# Configuring SMT server

1. Register the server with SUSEConnect: `SUSEConnect --regcode [REGCODE]`
2. Install `smt` package
3. Specify organization credentials via the SMT
[installation wizard](https://www.suse.com/documentation/sles-12/book_smt/data/smt_installation_wizard.html)
or by specifying the credentials in `/etc/smt.conf`:
```
[NU]
NUUrl = https://updates.suse.com/
NURegUrl = https://scc.suse.com/connect
NUUser = [organization_login]
NUPass = [organization_password]
ApiType = SCC
```
4. Get the list of repositories available for current subscription by running
`smt-sync`
5. Choose the repositories to enable mirroring for by running `smt-repos -e`.
It is advisable to specify the exact version and arch to minimize the number of
downloaded packages, i.e. run
```
smt-repos --enable-by-prod SLES,12.2,x86_64
```
And then disable the non-mandatory repos like Debuginfo-Pool, Debuginfo-Updates
and Source-Pool with `smt-repos -d -o`.
The resulting list of enabled repositories then would look as follows:
```
# smt-repos -o
.-------------------------------------------------------------------------------------------------------------------------------------------------.
| Mirror? | ID | Type | Name                         | Target        | Description                                    | Can be Mirrored | Staging |
+---------+----+------+------------------------------+---------------+------------------------------------------------+-----------------+---------+
| Yes     |  1 | nu   | SLES12-SP2-Installer-Updates | sle-12-x86_64 | SLES12-SP2-Installer-Updates for sle-12-x86_64 | Yes             | No      |
| Yes     |  2 | nu   | SLES12-SP2-Pool              | sle-12-x86_64 | SLES12-SP2-Pool for sle-12-x86_64              | Yes             | No      |
| Yes     |  3 | nu   | SLES12-SP2-Updates           | sle-12-x86_64 | SLES12-SP2-Updates for sle-12-x86_64           | Yes             | No      |
'---------+----+------+------------------------------+---------------+------------------------------------------------+-----------------+---------'
```
6. Run `smt-mirror` to download the repositories marked for mirroring.
The downloaded packages are stored under `/srv/www/htdocs/`.

The newly installed SMT server should appear in SCC with the login specified in
`/etc/zypp/credentials.d/SCCcredentials` file.

# Client registration

1. Install `smt` package
2. Register the client against the SMT server by running
```
/usr/share/doc/packages/smt/clientSetup4SMT.sh [SMT_SERVER_URL]
```
or by using `yast2 scc`.
3. Make sure that the repositories from the SMT server are enabled by running
`zypper repos`.

The following error is displayed on the client if repositories mandatory for the
client OS aren't enabled for mirroring or not mirrored on the SMT server:
```
Need to enable proper repos on the server:
Error: SCC returned 'Product not (fully) mirrored on this server' (422)
```

# References

1. [SMT manual for SLES 12](https://www.suse.com/documentation/sles-12/book_smt/data/book_smt.html)
2. [SMT manual for SLES 11](https://www.suse.com/documentation/smt11/)
