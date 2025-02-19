#!/bin/bash

INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="1.0"
VERSION_MINOR="0"
PROJECT_NAME="stenographer"
TMP_DIR="/tmp/$PROJECT_NAME"
GO="1.10"

echo "Initiating builder..."
apt update
apt -y install git wget curl sudo golang-$GO

export GOARCH=arm64
export GOROOT=/usr/lib/go-$GO
export GOPATH=/usr
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
go version

echo "Go get... "
go get github.com/google/stenographer

echo "Compiling... "
cd /usr/src
git clone https://github.com/google/stenographer
cd stenographer
cp /scripts/install.sh ./
chmod +x install.sh
export ROOT=$TMP_DIR
./install.sh

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
else
    echo "Failed! Exiting..."
    #exit 1;
fi

apt-get -y install ruby ruby-dev rubygems build-essential
gem install --no-ri --no-rdoc fpm

fpm -s dir -t deb -C ${TMP_DIR} \
	--name ${PROJECT_NAME} --version ${VERSION_MAJOR}  -p "${PROJECT_NAME}_${VERSION_MAJOR}-${INV}.${OS}.${ARCH}.deb" \
	--depends libleveldb-dev \
	--iteration 1 --deb-no-default-config-files --description ${PROJECT_NAME} .

ls -alF *.deb
cp -v *.deb /scripts

echo "done!"
