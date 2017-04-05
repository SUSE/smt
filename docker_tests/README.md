# Building the RPM package

1. Checkout the project from OBS into some directory:
```
mkdir -p ~/obs/
cd ~/obs/
osc -A https://api.suse.de co Devel:SMT:SLE-12-SMT
```
2. Make the tarball in git working directory by running `make package`
3. Update the data from OBS by the tarball and metadata from git:
```
cp package/* ~/obs/Devel:SMT:SLE-12-SMT/smt
```
4. Build the RPM package by running `osc build` in the OBS working directory.

# Testing the RPM package

1. The docker image expects the RPM package to be present in the following
locations:
```
smt_client/files/smt_current.rpm
smt_server/files/smt_current.rpm
```
2. Build docker images with `docker-compose build`
3. Run the containers with `docker-compose up`
4. After the containers finish loading, run the test suite inside `smt_server`
and `smt_client` containers, i.e.:
```
cd /rspec
bundle
rspec spec/smt_client # for the client container
rspec spec/smt_server # for the server container
```
