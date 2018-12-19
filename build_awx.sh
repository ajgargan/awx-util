#!/bin/bash

#Install epel
yum install -y epel-release

#Install dependencies via yum
yum install -y --enablerepo epel git gcc docker python27-pip python27-devel libffi-devel openssl-devel git curl util-linux

#Install python dependencies
/usr/bin/pip install -U docker ansible awscli

#Remove old crap
rm -rf awx*
rm -rf build-*

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


#Run build for each release version of AWX
for i in $(cat versions.txt)
do
	# running in the background
	./build_awx.sh $i >> build-$i.log 2>&1
	#/./build_awx.sh $i
done
[root@ip-10-36-53-8 testing]# cat build_awx.sh 
#!/bin/bash -x

# Clear old repos
#rm -rf awx*

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
