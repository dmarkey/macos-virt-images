#!/bin/bash -ex
NAME=$1
VERSION=$2
WORKDIR=$PWD/workdir_"$NAME"_"$VERSION"/
mkdir -p "$WORKDIR"
docker buildx build --output type=tar --build-arg VERSION="${VERSION}" . -f builders/"${NAME}"/Dockerfile > "$WORKDIR"/full_rootfs.tar
mkdir "$WORKDIR"/boot
tar -xvf "$WORKDIR"/full_rootfs.tar --directory "$WORKDIR" boot
find  "$WORKDIR"/boot -type l -delete
bsdtar -c -L -f "$WORKDIR"/rootfs.tar -p --exclude='boot/*' @"$WORKDIR"/full_rootfs.tar
tar -rvf "$WORKDIR"/rootfs.tar -C ./service/ etc/resolv.conf etc/hosts etc/hostname --owner=0 --group=0
virt-make-fs --type=ext4 -s 1G  "$WORKDIR"/rootfs.tar  "$WORKDIR"/root.img
virt-make-fs --type=vfat -s 100M  "$WORKDIR"/boot/  "$WORKDIR"/boot.img
tar -cvf output/"$NAME"-"$VERSION"-"$(uname -m)".tar -C "$WORKDIR" root.img boot.img
tar -rvf output/"$NAME"-"$VERSION"-"$(uname -m)".tar -C builders/"${NAME}" boot.cfg
gzip -f output/"$NAME"-"$VERSION"-"$(uname -m)".tar
rm -rf "$WORKDIR"
