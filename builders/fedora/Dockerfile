ARG VERSION
FROM fedora:${VERSION}
COPY service/macos-virt-service /usr/sbin/macos-virt-service
COPY service/macos-virt-service.service /etc/systemd/system/macos-virt-service.service
COPY builders/fedora/99-copy-kernel.install /etc/kernel/install.d/99-copy-kernel.install
RUN chmod 755 /etc/kernel/install.d/99-copy-kernel.install /usr/sbin/macos-virt-service
RUN yum install -y sudo openssh-server systemd-networkd kernel
COPY builders/fedora/init_fedora.sh /tmp/init_fedora.sh
RUN sh -ex /tmp/init_fedora.sh