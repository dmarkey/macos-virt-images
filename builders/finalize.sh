#!/bin/sh

NAME=$1
RELEASE=$2
ARCH=$3
BOOT_CONFIG=$4

cp $BOOT_CONFIG /working/$NAME/$RELEASE/$ARCH/boot/boot.cfg
umount /working/$NAME/$RELEASE/$ARCH/boot/ /working/$NAME/$RELEASE/$ARCH
cd /images/$NAME/$RELEASE/$ARCH/
tar zcvf package.tar.gz root.img boot.img 
