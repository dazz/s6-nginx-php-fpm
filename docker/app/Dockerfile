FROM alpine:3.18.4 as s6-overlay
ARG S6_TMP_PATH=/opt/s6-overlay
ARG SYSTEM_ARCH=x86_64
ARG S6_OVERLAY_VERSION=3.1.6.0
# install S6 Overlay
RUN set -eux; \
    apk add --no-cache xz; \
    mkdir -p ${S6_TMP_PATH}
# Docker is able to handle the https URL when you use ADD (no need for curl or wget)
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C ${S6_TMP_PATH} -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${SYSTEM_ARCH}.tar.xz /tmp
RUN tar -C ${S6_TMP_PATH} -Jxpf /tmp/s6-overlay-${SYSTEM_ARCH}.tar.xz


FROM php:8.2-fpm-alpine3.18 as base
ARG NGINX_VERSION=1.24.0-r7
ARG WORKDIR=/var/www/html
ARG S6_TMP_PATH=/opt/s6-overlay

# install php extensions installer
COPY --from=mlocati/php-extension-installer:2.1.64 /usr/bin/install-php-extensions /usr/local/bin/
# install nginx and packages
# now we got both nginx and php-fpm installed
RUN set -eux; \
    apk add --no-cache \
      nginx=${NGINX_VERSION} \
    && install-php-extensions  \
          opcache \
    ;

# setup s6-overlay
ENV S6_VERBOSITY=5
# copy over S6 Overlay
COPY --from=s6-overlay ${S6_TMP_PATH} /
# copy files to start, run, terminate and finish the processes in the container with S6
COPY --chmod=755 ./docker/app/root /

WORKDIR ${WORKDIR}
EXPOSE 80
EXPOSE 443

CMD []
ENTRYPOINT ["/init"]

FROM base as dev
COPY --from=composer:2.6.5 /usr/bin/composer /usr/bin/composer
RUN set -eux; \
    apk add --no-cache git \
#    && install-php-extensions xdebug
;