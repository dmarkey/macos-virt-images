#!/bin/bash -e
NAME=$1
RELEASE=$2
PACKAGES=$3
BOOT_CONFIG=$4
ARCH=$5
bash -e ../prepare_image.sh "$NAME" "$RELEASE" "$ARCH"

ROOT=/working/$NAME/$RELEASE/$ARCH

if  [ "$ARCH" = "x86_64" ]; then
  DEBIAN_ARCH=amd64
else
  DEBIAN_ARCH=arm64
fi
mkdir -p "$ROOT"/usr/sbin/
cp ../service.sh "$ROOT"/usr/sbin/macos-virt-service
chmod 755 "$ROOT"/usr/sbin/macos-virt-service

mkdir "$ROOT"/dev
mkdir "$ROOT"/proc
mkdir "$ROOT"/sys

if [[ "$PACKAGES" != *"linux"* ]]; then
  PACKAGES=$PACKAGES,linux-image-$DEBIAN_ARCH
fi

debootstrap --components=main,restricted,universe,multiverse --arch=$DEBIAN_ARCH --exclude=cloud-initramfs-copymods --include="$PACKAGES,openssh-server,sudo,initramfs-tools" "$RELEASE" "$ROOT"

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

cat << EOF >> "$ROOT"/tmp/init.sh
#!/bin/sh
useradd -m macos-virt
gpasswd -a macos-virt sudo
echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
echo fuse >> /etc/modules
systemctl enable getty@hvc0
systemctl enable ssh
systemctl enable macos-virt-service
systemctl enable systemd-networkd
echo "[Match]" > /etc/systemd/network/20-wired.network"
echo "Name=enp0*" >> /etc/systemd/network/20-wired.network"
echo "[Network]" >> /etc/systemd/network/20-wired.network"
echo "DHCP=yes" >> /etc/systemd/network/20-wired.network"
echo 'root:password' | chpasswd
echo "/dev/vda      /    ext4   defaults        0 0" >> /etc/fstab
echo "/dev/vdb      /boot    udf   defaults        0 0" >> /etc/fstab
echo localhost > /etc/hostname
EOF

chroot "$ROOT" /bin/sh /tmp/init.sh
bash ../finalize.sh $NAME $RELEASE $ARCH $BOOT_CONFIG

