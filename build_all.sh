#!/bin/sh -e
sudo apt-get install -y libguestfs-tools libarchive-tools
mkdir -p output || true
sudo ./build.sh alpine 3.14
#sudo bash build.sh alpine 3.15
#sudo bash build.sh alpine 3.16
