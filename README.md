# awx-util

## Why?
So I can be sure the builds will work for the awx quickstart

## Usage:
Build a single release using official images
```
./build_awx.sh -v <release_version>
```
Build a single release building the containers (currently problematic)
```
./build_awx.sh -b -v <release_version>
```
Build a single release building the containers with official Logos (currently problematic for 1.X)
```
./build_awx.sh -l -v <release_version>
```
Build all release versions using Dockerhub images
```
./build_all_awx.sh 
```
## Config
versions.txt
```
simply a list of release versions
```
probably need to have a config file and parameterize the outer shell script

## Outputs
This will show the Ansible result for all builds
```
grep failed= build*log
```
Logs for each of the containers are logged (useful for spotting problems in the containers)
```
build-<version>-awx_task.log
build-<version>-awx_web.log
build-<version>-rabbitmq.log
build-<version>-postgres.log
build-<version>-memcached.log
```
