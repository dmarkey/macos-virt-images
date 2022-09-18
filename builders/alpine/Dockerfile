ARG VERSION
FROM alpine:${VERSION}
COPY service/macos-virt.rc /etc/init.d/macos-virt
COPY service/macos-virt-service /usr/sbin/macos-virt-service
RUN chmod 755 /etc/init.d/macos-virt /usr/sbin/macos-virt-service
COPY builders/alpine/init_alpine.sh /tmp/init_alpine.sh
RUN sh -x /tmp/init_alpine.sh