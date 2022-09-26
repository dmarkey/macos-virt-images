#!/bin/bash -e
NAME=$1
VERSION=$2

docker buildx build --output type=tar --build-arg VERSION="${VERSION}" . -f builders/"${NAME}"/Dockerfile > $$full_rootfs.tar
rm -rf boot || true
mkdir $$boot
tar -xvf $$full_rootfs.tar  boot -C $$boot
find $$boot -type l -delete
bsdtar -c -L -f $$rootfs.tar -p --exclude='boot/*' @$$full_rootfs.tar
tar -rvf  $$rootfs.tar -C ./service/ etc/resolv.conf etc/hosts etc/hostname --owner=0 --group=0
virt-make-fs --type=ext4 -s 1G $$rootfs.tar $$root.img
virt-make-fs --type=vfat -s 100M ./$$boot/ $$boot.img
tar -cvf output/"$NAME"-"$VERSION"-"$(uname -m)".tar $$root.img $$boot.img
tar -rvf output/"$NAME"-"$VERSION"-"$(uname -m)".tar  -C builders/"${NAME}" boot.cfg
gzip -f output/"$NAME"-"$VERSION"-"$(uname -m)".tar
rm -rf $$boot $$full_rootfs.tar $$boot.img $$root.img
