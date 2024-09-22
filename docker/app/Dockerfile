FROM hakindazz/s6-overlay-base:latest AS s6-overlay
FROM mlocati/php-extension-installer:2.4 AS php-extension-installer
FROM composer:2.7 AS composer
FROM php:8.3-fpm-alpine3.20 AS php

FROM php AS prod
ARG NGINX_VERSION=1.26.2-r0
ARG WORKDIR=/var/www/html

# install php extensions installer
COPY --from=php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
# install nginx and packages
# now we got both nginx and php-fpm installed
RUN set -eux; \
    apk add --no-cache \
      nginx=${NGINX_VERSION} \
    && apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && install-php-extensions  \
      pdo_mysql \
      opcache \
    && apk del --no-network .build-deps \
    ;

# setup s6-overlay
ENV S6_VERBOSITY=5
# copy over S6 Overlay
COPY --from=s6-overlay /s6/root /
# copy files to start, run, terminate and finish the processes in the container with S6
COPY --chmod=755 ./docker/app/root /

WORKDIR ${WORKDIR}
EXPOSE 80
EXPOSE 443

CMD []
ENTRYPOINT ["/init"]

FROM prod AS dev
ARG UID
ARG GID
COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN set -eux; \
    apk add --no-cache git shadow \
#    && install-php-extensions xdebug \
    && groupmod -g ${GID} www-data \
    && usermod -u ${UID} www-data \
    && chown -R www-data:www-data ${WORKDIR} \
;