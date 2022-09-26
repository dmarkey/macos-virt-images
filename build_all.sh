#!/bin/sh
apt-get install -y libguestfs-tools libarchive-tools
mkdir -p output || true
bash build.sh alpine 3.16
