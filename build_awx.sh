#~/bin/bash -x
# Create build dir
mkdir -p build

# Copy projects into build
cp -dpru awx build/
cp -drpu awx-logos build/

cd build/awx
pwd
# if we get given a release checkout that version
if [ "X$1" != "X" ]
then
   git checkout $1 
fi

# Don't use docker_hub images
sed -i "s/^dockerhub/#docker/g" installer/inventory

# Build logos in
sed -i "s/^# awx_official=false/awx_official=true/g" installer/inventory

cd installer
ansible-playbook -i inventory install.yml

# Install / awx / build 
cd ../../..

# cleanup
rm -rf build
