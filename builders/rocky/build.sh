#!/bin/bash -e
NAME=$1
RELEASE=$2
PACKAGES=$3
BOOT_CONFIG=$4
ARCH=$5
bash -e ../prepare_image.sh "$NAME" "$RELEASE" "$ARCH"

ROOT=/working/$NAME/$RELEASE/$ARCH

DOWNLOAD_URL=https://github.com/rocky-linux/sig-cloud-instance-images/raw/Rocky-$RELEASE-$ARCH/rocky-$RELEASE-docker-$ARCH.tar.xz
mkdir -p "$ROOT"/usr/sbin/
cp ../service.sh "$ROOT"/usr/sbin/macos-virt-service
chmod 755 "$ROOT"/usr/sbin/macos-virt-service
cd $ROOT
curl -L $DOWNLOAD_URL | tar Jxvf -
mount --bind /dev $ROOT/dev
mount --bind /sys $ROOT/sys
mount --bind /proc $ROOT/proc
echo "nameserver 8.8.8.8" > $ROOT/etc/resolv.conf
cat << 'EOF' >> "$ROOT"/etc/systemd/system/macos-virt-service.service
[Unit]

Description=Macos-Virt Agent.

[Service]

ExecStart=/usr/sbin/macos-virt-service
After=network-online.target
Wants=network-online.target

[Install]

WantedBy=multi-user.target
EOF
cat << 'EOF' >> "$ROOT"/tmp/init.sh
#!/bin/sh
dnf -y upgrade
rpm  --rebuilddb
dnf install -y dnf-plugin-config-manager
rpm  --rebuilddb
dnf -y install kernel sudo openssh-server NetworkManager
echo "fuse" >> /etc/modules
echo "/dev/vda      /    ext4   defaults        0 0" >> /etc/fstab
echo "/dev/vdb      /boot    udf   defaults        0 0" >> /etc/fstab
systemctl enable getty@hvc0
systemctl enable sshd
systemctl enable NetworkManager
systemctl enable macos-virt-service
useradd -m macos-virt
gpasswd -a macos-virt wheel
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo root:password | chpasswd
EOF
chroot "$ROOT" /bin/sh /tmp/init.sh
cd -
umount "$ROOT"/dev "$ROOT"/proc "$ROOT"/sys
bash ../finalize.sh $NAME $RELEASE $ARCH $BOOT_CONFIG
