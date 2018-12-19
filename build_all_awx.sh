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
