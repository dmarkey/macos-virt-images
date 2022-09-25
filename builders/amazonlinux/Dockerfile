ARG VERSION
FROM amazonlinux:${VERSION}
COPY service/macos-virt-service /usr/sbin/macos-virt-service
COPY service/macos-virt-service.service /etc/systemd/system/macos-virt-service.service
RUN chmod 755 /usr/sbin/macos-virt-service
COPY builders/amazonlinux/init_al2.sh /tmp/init_al2.sh
RUN sh -ex /tmp/init_al2.sh