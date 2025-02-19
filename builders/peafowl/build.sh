#!/bin/bash

INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="1.0"
VERSION_MINOR="0"
PROJECT_NAME="peafowl"
TMP_DIR="/tmp/$PROJECT_NAME"

echo "Initiating builder..."
apt update
apt -y install git wget curl
apt -y install build-essential automake autoconf libpcap0.8-dev flex bison cmake python python-dev

mkdir =p "$TMP_DIR"

cd /usr/src
git clone git://github.com/DanieleDeSensi/Peafowl.git

echo "Compiling $PROJECT_NAME ..."
cd Peafowl
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${TMP_DIR} ../
#cmake ../
make
make install prefix=${TMP_DIR}

mkdir -p ${TMP_DIR}/usr/include
cp -R /usr/include/peafowl ${TMP_DIR}/usr/include/
mkdir -p ${TMP_DIR}/usr/lib
cp -R /usr/lib/libpeafowl* ${TMP_DIR}/usr/lib/

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
else
    echo "Failed! Exiting..."
#    exit 1;
fi

apt-get -y install ruby ruby-dev rubygems build-essential
gem install --no-ri --no-rdoc fpm

fpm -s dir -t deb -C ${TMP_DIR} \
	--name ${PROJECT_NAME} --version ${VERSION_MAJOR}  -p "${PROJECT_NAME}_${VERSION_MAJOR}-${INV}.${OS}.${ARCH}.deb" \
	--iteration 1 --deb-no-default-config-files --description ${PROJECT_NAME} .

ls -alF *.deb
cp -v *.deb /scripts/


