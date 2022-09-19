#!/bin/sh -e
groupadd sudo
useradd -m macos-virt
gpasswd -a macos-virt sudo
echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
systemctl enable sshd
systemctl enable macos-virt-service
systemctl enable systemd-networkd
systemctl disable systemd-resolved
systemctl enable getty@hvc0
mkdir -p /etc/systemd/network
echo "[Match]" > /etc/systemd/network/20-wired.network
echo "Name=enp0*" >> /etc/systemd/network/20-wired.network
echo "[Network]" >> /etc/systemd/network/20-wired.network
echo "DHCP=yes" >> /etc/systemd/network/20-wired.network
echo 'root:password' | chpasswd
echo "/dev/vda      /    ext4   defaults        0 0" >> /etc/fstab
echo "/dev/vdb      /boot    vfat   defaults        0 0" >> /etc/fstab
echo 'LANG="en_US.UTF-8"' >> /etc/environment
echo 'LC_ALL="en_US.UTF-8"' >> /etc/environment
echo 'LC_CTYPE="en_US.UTF-8"' >> /etc/environment