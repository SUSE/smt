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
location:
```
smt_server/files/smt_current.rpm
```
2. Build docker images with `docker-compose build`
3. Run the containers with `docker-compose up`
4. After the containers finish loading, find out the name of the container
by running `docker-exec ps`
5. To run SMT server tests in the `smt_server` container run:
```
docker-compose exec smt_server bash
cd /rspec
bundle
rspec spec/smt_server
```
6. To run SMT client tests in the `smt_client` container run:
```
docker-compose exec smt_client bash
cd /rspec
bundle
rspec spec/smt_client
```
