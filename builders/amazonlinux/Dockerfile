ARG VERSION
FROM amazonlinux:${VERSION}
COPY service/macos-virt-service /usr/sbin/macos-virt-service
COPY service/macos-virt-service.service /etc/systemd/system/macos-virt-service.service
RUN chmod 755 /usr/sbin/macos-virt-service
RUN amazon-linux-extras install -y kernel-5.10
RUN yum install -y sudo openssh-server systemd-networkd
COPY builders/amazonlinux/init_al2.sh /tmp/init_al2.sh
RUN sh -x /tmp/init_al2.sh