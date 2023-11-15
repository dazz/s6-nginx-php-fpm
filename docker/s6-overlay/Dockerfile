FROM ubuntu:23.10
ARG S6_OVERLAY_VERSION=3.1.6.0

ENV S6_VERBOSITY=1

RUN apt-get update && apt-get install -y nginx xz-utils
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
CMD ["/usr/sbin/nginx"]

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz


FROM alpine:3.18.4 as s6-overlay
ARG SYSTEM_ARCH=x86_64
ARG S6_OVERLAY_VERSION=3.1.6.0
# install S6 Overlay
RUN set -eux; \
    apk add --no-cache xz; \
    mkdir -p /opt/s6
# Docker is able to handle the https URL when you use ADD (no need for curl or wget)
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C /opt/s6 -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${SYSTEM_ARCH}.tar.xz /tmp
RUN tar -C /opt/s6 -Jxpf /tmp/s6-overlay-${SYSTEM_ARCH}.tar.xz
ENTRYPOINT ["/init"]