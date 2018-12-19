#!/bin/bash

#Install epel
yum install -y epel-release

#Install dependencies via yum
yum install -y --enable epel  git gcc docker python27-pip python27-devel libffi-devel openssl-devel git curl util-linux

#Install python dependencies
/usr/bin/pip install -U docker ansible awscli

#Run build for each release version of AWX
for i in $(cat versions.txt)
do
	# running in the background
	./build_awx.sh $i & 2>&1 >> build-$i.log
done
