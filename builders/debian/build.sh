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
debootstrap --components=main,restricted,universe,multiverse --arch=$DEBIAN_ARCH --include="$PACKAGES,linux-image-$DEBIAN_ARCH" "$RELEASE" "$ROOT"

cat << 'EOF' >> "$ROOT"/etc/systemd/system/macos-virt-service.service
[Unit]

Description=Macos-Virt Agent.

[Service]

ExecStart=/usr/sbin/macos-virt-service

[Install]

WantedBy=multi-user.target
EOF

cat << EOF >> "$ROOT"/tmp/init.sh
#!/bin/sh
useradd -m macos-virt
gpasswd -a macos-virt sudo
echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
systemctl enable getty@hvc0
systemctl enable ssh
systemctl enable macos-virt-service
echo "/dev/vda      /    ext4   defaults        0 0" >> /etc/fstab
echo "/dev/vdb      /boot    udf   defaults        0 0" >> /etc/fstab
echo "network:" >> /etc/netplan/network.yaml
echo "    version: 2" >> /etc/netplan/network.yaml
echo "    renderer: networkd" >> /etc/netplan/network.yaml
echo "    ethernets:" >> /etc/netplan/network.yaml
echo "        enp0s1:" >>  /etc/netplan/network.yaml
echo "            dhcp4: true" >> /etc/netplan/network.yaml
netplan generate
EOF

chroot "$ROOT" /bin/sh /tmp/init.sh
bash ../finalize.sh $NAME $RELEASE $ARCH $BOOT_CONFIG

