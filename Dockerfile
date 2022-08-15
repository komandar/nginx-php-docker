ARG PHP_VERSION=8.1
FROM php:8.1-fpm-alpine

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# Install phpredis from source
RUN wget -O /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/5.3.7.tar.gz \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mkdir -p /usr/src/php/ext \
    && mv phpredis-* /usr/src/php/ext/redis

# Install packages and extensions from apk
RUN apk add --no-cache --update \
    # Install general packages
    git \
    icu-dev \
    nginx \
    unzip \
    # Install gd for image transformations
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    # Install local mail server
    msmtp \
    # Install postgresql package
    postgresql-dev \
    # Install zip function
    libzip-dev \
    zip \
    # Configure image library
    && docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    # Configure PHP extensions for use in Docker
    && docker-php-ext-install -j$(nproc) \
    gd \
    opcache \
    pdo_mysql \
    pdo_pgsql \
    redis \
    zip \
    # Setup Nginx directories, permissions, and one-off configurations
    && mkdir -p /var/run/nginx \
    && chown -R www-data:www-data /var/run/nginx /var/lib/nginx /var/log/nginx \
    && sed -i 's|user nginx;|#user www-data;|' /etc/nginx/nginx.conf \
    && sed -i 's|user =|;user =|' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's|group =|;group =|' /usr/local/etc/php-fpm.d/www.conf \
    # Install the latest version of Composer
    && wget -q -O - https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    # Cleanup
    && rm -rf /var/cache/apk/* /tmp/*

COPY /config/msmtprc /etc/msmtprc
COPY /config/nginx.conf /etc/nginx/http.d/default.conf
COPY /config/php-general.ini /usr/local/etc/php/conf.d/php-general-cfg.ini
COPY /config/php-opcache.ini /usr/local/etc/php/conf.d/php-opcache-cfg.ini
COPY /scripts/start.sh /etc/start.sh
COPY --chown=www-data:www-data src/ /var/www/html/public

WORKDIR /var/www/html

EXPOSE 80 443

USER www-data:www-data

ENTRYPOINT ["/etc/start.sh"]
