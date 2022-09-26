#!/bin/sh -e
useradd -m macos-virt
gpasswd -a macos-virt sudo
echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
systemctl enable ssh
systemctl enable macos-virt-service
systemctl enable systemd-networkd
systemctl disable systemd-resolved
mkdir -p /etc/systemd/network
echo "[Match]" > /etc/systemd/network/20-wired.network
echo "Name=enp0*" >> /etc/systemd/network/20-wired.network
echo "[Network]" >> /etc/systemd/network/20-wired.network
echo "DHCP=yes" >> /etc/systemd/network/20-wired.network
echo "/dev/vda      /    ext4   defaults        0 0" >> /etc/fstab
echo "/dev/vdb      /boot    vfat   defaults        0 0" >> /etc/fstab
echo localhost > /etc/hostname
rm /etc/kernel/postinst.d/xx-update-initrd-links || true
locale-gen "en_US.UTF-8"