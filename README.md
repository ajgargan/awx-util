# awx-util
The idea is to put all my scripts for manually testing in a single place

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
