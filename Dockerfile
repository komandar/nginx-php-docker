ARG PHP_VERSION=8.1
FROM php:8.1-fpm-alpine

# PHP_CPPFLAGS are used by the docker-php-ext-* scripts
ARG PHP_CPPFLAGS="$PHP_CPPFLAGS"

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# Install Nginx & PHP packages and extensions
RUN apk add --no-cache --update \
    # Install packages required by PHP/Laravel
    git \
    icu-dev \
    nginx \
    unzip \
    # Install mail server
    msmtp \
    # Install gd for image functions
    freetype-dev \
    libwebp-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    # Install zip for csv functions
    libzip-dev \
    zip \
    # Install postgresql packages
    postgresql-dev \
    # Install phpredis
    pcre-dev ${PHPIZE_DEPS} \
    && pecl install redis \
    && apk del pcre-dev ${PHPIZE_DEPS} \
    # Configure image library
    && docker-php-ext-configure gd \
    --with-jpeg \
    --with-webp \
    --with-freetype \
    # Configure PHP extensions for use in Docker
    && docker-php-ext-install \
    gd \
    redis \
    opcache \
    pdo_mysql \
    pdo_pgsql \
    zip \
    # Setup Nginx directories, permissions, and one-off configurations
    && mkdir -p /var/run/nginx \
    && chown -R www-data:www-data /var/run/nginx /var/lib/nginx /var/log/nginx \
    && sed -i 's|user nginx;|#user www-data;|' /etc/nginx/nginx.conf \
    && sed -i 's|user =|;user =|' /usr/local/etc/php-fpm.d/www.conf \
    && sed -i 's|group =|;group =|' /usr/local/etc/php-fpm.d/www.conf \
    # Install the latest version of Composer
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    # Cleanup
    && rm -rf /var/cache/apk/* /tmp/*

COPY /config/nginx.conf /etc/nginx/http.d/default.conf
COPY /config/php-opcache.ini /usr/local/etc/php/conf.d/php-opcache-cfg.ini
COPY /config/php-general.ini /usr/local/etc/php/conf.d/php-general-cfg.ini
COPY /config/msmtprc /etc/msmtprc
COPY /scripts/start.sh /etc/start.sh
COPY --chown=www-data:www-data src/ /var/www/html/public

WORKDIR /var/www/html

EXPOSE 80 443

USER www-data:www-data

ENTRYPOINT ["/etc/start.sh"]
