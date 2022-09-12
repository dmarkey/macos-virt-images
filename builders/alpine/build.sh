#!/bin/bash -e
NAME=$1
RELEASE=$2
PACKAGES=$3
BOOT_CONFIG=$4
ARCH=$5
bash -e ../prepare_image.sh "$NAME" "$RELEASE" "$ARCH"

ROOT=/working/$NAME/$RELEASE/$ARCH

DOWNLOAD_URL=https://dl-cdn.alpinelinux.org/alpine/v$RELEASE/releases/$ARCH/alpine-minirootfs-$RELEASE.0-$ARCH.tar.gz
mkdir -p "$ROOT"/usr/sbin/
cp ../service.sh "$ROOT"/usr/sbin/macos-virt-service
chmod 755 "$ROOT"/usr/sbin/macos-virt-service
cd $ROOT
curl $DOWNLOAD_URL | tar zxvf -
mount --bind /dev $ROOT/dev
mount --bind /sys $ROOT/sys
mount --bind /proc $ROOT/proc
echo "nameserver 8.8.8.8" >> $ROOT/etc/resolv.conf
cat << 'EOF' >> "$ROOT"/etc/init.d/macos-virt
#!/sbin/openrc-run
name="macos-virt"
command="/usr/sbin/macos-virt-service"
command_background="yes"
pidfile="/var/run/${RC_SVCNAME}.pid"
depend() {
  after networking
}
rc_crashed_start=YES
EOF
chmod 755 "$ROOT"/etc/init.d/macos-virt
cat << 'EOF' >> "$ROOT"/tmp/init.sh
#!/bin/sh
apk update
apk add openrc linux-virt openssh-server-pam
apk add e2fsprogs-extra udftools
apk add busybox-initscripts
apk add sudo
rc-update add syslog boot
rc-update add localmount
rc-update add mdev
rc-update add hostname
rc-update add networking
rc-update add modules
rc-update add root
rc-update add sysfs
rc-update add procfs
rc-update add sysfsconf
rc-update add acpid
rc-update add sshd
rc-update add local
rc-update add modloop
rc-update add hwdrivers
rc-update add bootmisc
rc-update add macos-virt
echo "fuse" >> /etc/modules
echo "virtio_pci" >> /etc/modules
echo "/dev/vda      /    ext4   defaults        0 0" >> /etc/fstab
echo "/dev/vdb      /boot    udf   defaults        0 0" >> /etc/fstab
echo "hvc0::respawn:/sbin/getty -L 0 hvc0 vt100" >> /etc/inittab
echo "alpine" > /etc/hostname
echo "auto lo" > /etc/network/interfaces
echo "iface lo inet loopback" >> /etc/network/interfaces
echo "auto eth0" >> /etc/network/interfaces
echo "iface eth0 inet dhcp" >> /etc/network/interfaces
echo "UsePAM yes" >> /etc/ssh/sshd_config
echo "kernel_glob=vmlinuz-virt" > /boot/boot.cfg
echo "initrd_glob=initramfs-virt" >> /boot/boot.cfg
echo "cmdline=console=hvc0 irqfixup modules=ext4,virtio_console,isofs,udf quiet root=/dev/vda" >> /boot/boot.cfg
echo root:password | chpasswd
kernel_version=$(ls /lib/modules/)
depmod -a $kernel_version
mkinitfs -c /etc/mkinitfs/mkinitfs.conf -b / $kernel_version
adduser macos-virt -D -s /bin/sh
addgroup macos-virt wheel
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
EOF
chroot "$ROOT" /bin/sh /tmp/init.sh
cd -
umount "$ROOT"/dev "$ROOT"/proc "$ROOT"/sys
bash ../finalize.sh $NAME $RELEASE $ARCH $BOOT_CONFIG
