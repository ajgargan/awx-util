#!/bin/bash

#Install epel
echo "Install epel"
yum install -y epel-release >/dev/null 2>&1

#Install dependencies via yum
echo "Install rpm dependencies"
yum install -y --enablerepo epel git gcc docker curl docker-compose python27-pip python27-devel libffi-devel openssl-devel curl util-linux > /dev/null 2>&1

#Install python dependencies
echo "Install python dependencies"
/usr/bin/pip install -U docker ansible awscli >/dev/null 2>&1

#Remove old crap
echo "Cleaning up old builds and git project pulls"
rm -rf awx*
rm -rf build-*

# Check out awx
if [ ! -d "awx" ]
then
        echo "Checkout awx"
        git clone https://github.com/ansible/awx.git
fi

# Make sure docker is running 
echo "Make sure docker is running"
service docker restart

# Check out awx-logos
if [ ! -d "awx-logos" ]
then
        echo "Checkout awx-logos"
        git clone https://github.com/ansible/awx-logos.git
fi

echo "Stop all running containers"
# Stop all running containers
if [ "X" != "X$(docker ps -q)" ]
then
        docker stop $(docker ps -q)
        docker rm -v $(docker ps -a -q) >/dev/null 2>&1
fi

echo "Purge existing container images"
# purge containers
docker volume prune -f
docker container prune -f
docker image prune -a -f
docker system prune -a -f

#Run build for each release version of AWX
for i in $(cat versions.txt)
do
        # running in the background
        ./build_awx.sh -v $i >> build-$i.log 2>&1
        #/./build_awx.sh $i
        # Stop all running containers
        echo "Give containers 4 minutes to do their thing"
        sleep 240
        #echo "Checking the task container logs"
        echo "Add container logs to build log"
        docker logs awx_task >> build-$i-awx_task.log 2>&1
        docker logs awx_web >> build-$i-awx_web.log 2>&1
        docker logs postgres >> build-$i-postgres.log 2>&1
        docker logs memcached >> build-$i-memcached.log 2>&1
        docker logs rabbitmq >> build-$i-rabbitmq.log 2>&1

        # This gives us the changes in terms of the ENV etc.
        echo "Add container inspect to build log"
        docker inspect awx_task >> build-$i-awx_task-inspect.json 2>&1
        docker inspect awx_web >> build-$i-awx_web-inspect.json 2>&1
        docker inspect postgres >> build-$i-postgres-inspect.json 2>&1
        docker inspect memcached >> build-$i-memcached-inspect.json 2>&1
        docker inspect rabbitmq >> build-$i-rabbitmq-inspect.json 2>&1

        echo "Connecting to the awx_web host to check"
        curl -o build-$i-awx_web.html http://localhost/
        curl --trace-ascii http://localhost/ >> build-$i-curl-trace-ascii.log

        #sleep 240      
        echo "stopping containers"
        if [ "X" != "X$(docker ps -a -q)" ]
        then
                docker stop $(docker ps -a -q) >/dev/null 2>&1
                docker rm -v $(docker ps -a -q) >/dev/null 2>&1
        fi
        sleep 20
done
# purge containers
echo "purging containers"
docker volume prune -f
docker container prune -f
docker image prune -a -f
docker system prune -a -f

#collate all of these
grep "failed=" *.log
