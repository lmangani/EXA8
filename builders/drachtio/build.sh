#!/bin/bash

INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="0.8"
VERSION_MINOR="1"
PROJECT_NAME="drachtio"
TMP_DIR="/tmp/$PROJECT_NAME"
ENV DEBIAN_FRONTEND noninteractive
VERSION=0.8

echo "Initiating builder..."

mkdir -p ${TMP_DIR}/usr/local
apt update
apt-get update -qq && \
apt-get install -y build-essential git libssl-dev libtool libtool-bin autoconf \
automake zlib1g-dev cmake libcurl4-openssl-dev 

cd /usr/src
git clone --depth=50 --branch=develop git://github.com/davehorton/drachtio-server.git && cd drachtio-server
git submodule update --init --recursive
./autogen.sh
mkdir build && cd $_
../configure CPPFLAGS='-DNDEBUG' CXXFLAGS='-O0'

make
make install exec_prefix=${TMP_DIR} prefix=${TMP_DIR}

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
else
    echo "Failed! Exiting..."
    exit 1;
fi

apt-get -y install ruby ruby-dev rubygems
gem install --no-ri --no-rdoc fpm

fpm -s dir -t deb -C ${TMP_DIR} \
	--name ${PROJECT_NAME} --version ${VERSION_MAJOR}  -p "${PROJECT_NAME}_${VERSION_MAJOR}-${INV}.${OS}.${ARCH}.deb" \
	--iteration 1 --deb-no-default-config-files --description ${PROJECT_NAME} .

ls -alF *.deb
cp -v *.deb /scripts/


