#!/bin/sh -e
apt-get install -y libguestfs-tools libarchive-tools
mkdir -p output || true
./build.sh alpine 3.14
./build.sh alpine 3.15
./build.sh alpine 3.16
./build.sh ubuntu 20.04
./build.sh ubuntu 22.04
./build.sh amazonlinux 2
./build.sh fedora 36
