FROM serversideup/php:8.2-fpm-nginx

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    php8.2-sqlite3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*