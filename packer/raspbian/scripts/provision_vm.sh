#!/bin/bash
# Based on https://github.com/solo-io/packer-builder-arm-image/blob/master/provision.sh
set -x

sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
sudo apt-get install -y software-properties-common

sudo add-apt-repository --yes ppa:gophers/archive
sudo apt-add-repository --yes ppa:ansible/ansible

# Install required packages
sudo apt-get update
sudo apt-get install -y \
    kpartx \
    qemu-user-static \
    git \
    wget \
    curl \
    unzip \
    ppa-purge \
    golang-1.9-go

# Also set them while we work:
export GOROOT=/usr/lib/go-1.9
export GOPATH=$HOME/work
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Install go dep
go get -u github.com/golang/dep/cmd/dep

# Download and install packer
wget https://releases.hashicorp.com/packer/1.2.1/packer_1.2.1_linux_amd64.zip \
    -q -O /tmp/packer_1.2.1_linux_amd64.zip
pushd /tmp
unzip packer_1.2.1_linux_amd64.zip
sudo cp packer /usr/local/bin
popd

mkdir -p $GOPATH/src/github.com/solo-io/
pushd $GOPATH/src/github.com/solo-io/
git clone https://github.com/solo-io/packer-builder-arm-image
pushd ./packer-builder-arm-image
dep ensure
go build

mkdir -p /home/vagrant/.packer.d/plugins
cp packer-builder-arm-image /home/vagrant/.packer.d/plugins/
popd; popd

rm -rf $GOPATH
sudo ppa-purge -y ppa:gophers/archive
sudo apt-get remove --purge --auto-remove -y \
    software-properties-common \
    git \
    wget \
    curl \
    unzip \
    ppa-purge \
    golang-1.9-go
sudo apt-get purge -y --auto-remove
