# Commiting the changes to OBS

1. Update the version in the `Makefile` and `package/smt.spec` as necessary
2. Update the changelog in `package/smt.changes` file
3. Run `make package`
4. Checkout the devel project from OBS
5. Copy everything from `package` directory into `smt` subdirectory in the
OBS project working copy
6. Remove the tarball with the previous version, example `iosc status` output:
```
# ~/obs/Devel:SMT:SLE-12-SMT/smt> iosc status
!    smt-3.0.24.tar.bz2
?    smt-3.0.25.tar.bz2
M    smt.changes
M    smt.spec
```
7. Run `iosc addremove`:
```
# ~/obs/Devel:SMT:SLE-12-SMT/smt> iosc addremove
A    smt-3.0.25.tar.bz2
D    smt-3.0.24.tar.bz2
```
8. After this the changes should be properly tracked:
```
# ~/obs/Devel:SMT:SLE-12-SMT/smt> iosc status
D    smt-3.0.24.tar.bz2
A    smt-3.0.25.tar.bz2
M    smt.changes
M    smt.spec
```
9. Commit the changes:
```
# ~/obs/Devel:SMT:SLE-12-SMT/smt> iosc ci
Deleting    smt-3.0.24.tar.bz2
Sending    smt.changes
Sending    smt.spec
Sending    smt-3.0.25.tar.bz2
Transmitting file data ...
Committed revision 42.
```

### Listing maintained package branches

To get the list of all maintained smt branches run `iosc maintained smt`:
```
# ~/obs/Devel:SMT:SLE-12-SMT/smt> iosc maintained smt
SUSE:SLE-10-SP3:Update:Test/smt
SUSE:SLE-11-SP2:Update/smt
SUSE:SLE-11-SP3:Update/smt
SUSE:SLE-11:Update/smt
SUSE:SLE-12-SP1:Update/smt using sources from SUSE:Maintenance:4270/smt.SUSE_SLE-12-SP1_Update
```

### Issuing a maintenance request

Issuing an MR for SLE-11-SP3 in this example:

```
# ~/obs/Devel:SMT:SLE-11-SMT-SP3/smt> iosc mr Devel:SMT:SLE-11-SMT-SP3 smt SUSE:SLE-11-SP3:Update
Using target project 'SUSE:Maintenance'
132177
```

After an MR is issued it should show up in the output of
`iosc request list` command and also in the "Outgoing requests tab"
in OBS web-interface.
