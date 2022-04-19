#!/bin/sh

BUILDER=$1
NAME=$2
RELEASE=$3
PACKAGES=$4
BOOT_CONFIG=$5
BOOT_CONFIG=$PWD/boot_configs/$BOOT_CONFIG

cd builders/$BUILDER
bash build.sh $NAME $RELEASE $PACKAGES $BOOT_CONFIG aarch64
#bash build.sh $NAME $RELEASE $PACKAGES $BOOT_CONFIG x86_64


