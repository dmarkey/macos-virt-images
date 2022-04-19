#!/bin/sh

NAME=$1
RELEASE=$2
ARCH=$3

mkdir -p /images/$NAME/$RELEASE/$ARCH || true
mkdir -p /working/$NAME/$RELEASE/$ARCH || true

dd if=/dev/zero of=/images/$NAME/$RELEASE/$ARCH/boot.img bs=1M count=100
dd if=/dev/zero of=/images/$NAME/$RELEASE/$ARCH/root.img bs=1M count=1000

mkfs.udf -l boot /images/$NAME/$RELEASE/$ARCH/boot.img
mkfs.ext4 /images/$NAME/$RELEASE/$ARCH/root.img

mount /images/$NAME/$RELEASE/$ARCH/root.img /working/$NAME/$RELEASE/$ARCH
mkdir /working/$NAME/$RELEASE/$ARCH/boot
mount /images/$NAME/$RELEASE/$ARCH/boot.img /working/$NAME/$RELEASE/$ARCH/boot

