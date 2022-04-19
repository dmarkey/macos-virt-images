#!/bin/sh

NAME=$1
RELEASE=$2
ARCH=$3
BOOT_CONFIG=$4

cp $BOOT_CONFIG /working/$NAME/$RELEASE/$ARCH/boot/boot.cfg
umount /working/$NAME/$RELEASE/$ARCH/boot/ /working/$NAME/$RELEASE/$ARCH
gzip /images/$NAME/$RELEASE/$ARCH/root.img
gzip /images/$NAME/$RELEASE/$ARCH/boot.img
