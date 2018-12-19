#!/bin/bash -x

# Clear old repos
rm -rf awx*

# Check out awx
if [ ! -d "awx" ]
then
	git clone https://github.com/ansible/awx.git
fi

# Check out awx-logos
if [ ! -d "awx-logos" ]
then
	git clone https://github.com/ansible/awx-logos.git
fi

if [ "X$1" != "X" ]
then
	version=$1
else
	version=latest
fi

# Create build dir
mkdir -p build-$version

# Copy projects into build
cp -v -dpru awx-logos/ build-$version/
cp -v -dpru awx/ build-$version/

cd build-$version/awx
pwd
ls -l --color

# if we get given a release checkout that version
if [ "$version" != "latest" ]
then
   git checkout $1 

   # Build official logos (Since we are using an official release)
   sed -i "s/^# awx_official=false/awx_official=true/g" installer/inventory
fi

# TODO: make this optional
# Don't use docker_hub images
sed -i "s/^dockerhub/#docker/g" installer/inventory

# run installer
cd installer
ansible-playbook -i inventory install.yml

# Install / awx / build 
cd ../../..

# cleanup
#rm -rf build-$version
