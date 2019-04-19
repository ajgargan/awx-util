#!/bin/bash 

usage() {
  echo "Usage: ${0} [-v <version>] [-b] [-l]"
  echo "-v <version_to_build>"
  echo "-b Build from source don't use official docker images"
  echo "-l Include Official AWX Logos this will cause a build from source"
  echo
}

# Defaults
logo=false
build=false

while getopts 'h?lbv:' flag; do
  case ${flag} in
    h) usage && exit 0 ;;
    l) logo="true" && build="true" ;;
    b) build="true" ;;
    v) version="${OPTARG}" ;;
    *) usage && exit 1 ;; # die "invalid option found" ;;
  esac
done


# If we are not supplied a version assume latest
: ${version:="latest"}

echo "version: $version"
#exit

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

# Create build dir
mkdir -p build-$version

# Copy projects into build
cp -v -dpru awx-logos/ build-$version/
cp -v -dpru awx/ build-$version/

cd build-$version/awx
pwd
#ls -l --color

# if we get given a release checkout that version
if [ "$version" != "latest" ]
then
   git checkout $version

   # Build official logos (Since we are using an official release)
   if [ $logo ]
   then
      sed -i "s/^# awx_official=false/awx_official=true/g" installer/inventory
   fi
fi

#
echo "BUILD: $build"
# Don't use docker_hub images
#if [ $build ]
#then
#   sed -i "s/^dockerhub_base/#dockerhub_base/g" installer/inventory
#
#fi

# run installer
cd installer

# link the dist folder so it can be found
ln -s ../dist/ dist

if [ "$version" != "latest" ]
then
        echo $version > ../VERSION
        echo -n "VERSION: "
        cat ../VERSION
        echo "$(pwd)/VERSION"
        # set image versions to use
        sed -i "s/^dockerhub_version=latest/dockerhub_version=$version/g" inventory
        sed -i "s/^postgres_data_dir=\/tmp\/pgdocker/postgres_data_dir=\/tmp\/$version\/pgdocker/g" inventory

        ansible-playbook -i inventory -e awx_version=$version install.yml
else
        ansible-playbook -i inventory install.yml
fi

# Install / awx / build
cd ../../..

# cleanup
#rm -rf build-$version

