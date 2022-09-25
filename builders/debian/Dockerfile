ARG VERSION
FROM debian:${VERSION}
COPY service/macos-virt-service /usr/sbin/macos-virt-service
COPY service/macos-virt-service.service /etc/systemd/system/macos-virt-service.service
RUN chmod 755 /usr/sbin/macos-virt-service
RUN apt-get -y update
RUN apt-get install -y linux-image-cloud-arm64 openssh-server iproute2 sudo locales netbase
RUN apt-get remove -y flash-kernel
COPY builders/ubuntu/init_ubuntu.sh /tmp/init_ubuntu.sh
RUN sh -x /tmp/init_ubuntu.sh