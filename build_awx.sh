#~/bin/bash -x
# Create build dir
mkdir -p build

# Clear old repos
rm -rf awx*

# Check out awx
git clone https://github.com/ansible/awx.git

# Check out awx-logos
git clone https://github.com/ansible/awx-logos.git

# Copy projects into build
cp -dpru awx build/
cp -drpu awx-logos build/

cd build/awx
pwd

# if we get given a release checkout that version
if [ "X$1" != "X" ]
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
rm -rf build
