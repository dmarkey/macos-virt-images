#!/bin/sh -e
apk update
apk add openrc linux-virt openssh-server-pam openssh
apk add e2fsprogs-extra udftools
apk add busybox-initscripts
apk add sudo
rc-update add localmount
rc-update add mdev
rc-update add hostname
rc-update add networking
rc-update add modules
rc-update add root
rc-update add procfs
rc-update add sysfsconf
rc-update add acpid
rc-update add syslog
rc-update add sshd
rc-update add local
rc-update add hwdrivers
rc-update add bootmisc
rc-update add macos-virt
echo "fuse" >> /etc/modules
echo "virtio_pci" >> /etc/modules
echo "/dev/vda      /    ext4   defaults        0 0" >> /etc/fstab
echo "/dev/vdb      /boot    vfat   defaults        0 0" >> /etc/fstab
echo "hvc0::respawn:/sbin/getty -L 0 hvc0 vt100" >> /etc/inittab
echo "alpine" > /etc/hostname
echo "auto lo" > /etc/network/interfaces
echo "iface lo inet loopback" >> /etc/network/interfaces
echo "auto eth0" >> /etc/network/interfaces
echo "iface eth0 inet dhcp" >> /etc/network/interfaces
echo "UsePAM yes" >> /etc/ssh/sshd_config
echo "kernel_glob=vmlinuz-virt" > /boot/boot.cfg
echo "initrd_glob=initramfs-virt" >> /boot/boot.cfg
echo "cmdline=console=hvc0 irqfixup quiet root=/dev/vda" >> /boot/boot.cfg
kernel_version=$(ls /lib/modules/)
depmod -a $kernel_version
mkinitfs -c /etc/mkinitfs/mkinitfs.conf -b / $kernel_version
adduser macos-virt -D -s /bin/sh
addgroup macos-virt wheel
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers