FROM php:7-fpm-alpine

MAINTAINER in_dow <in_dow [at] hotmail.com>

RUN apk add -U --no-cache mysql-client vim patch git gd \
    openldap libzip freetype libpng libjpeg-turbo

RUN set -ex \
    && apk add -U --no-cache --virtual .php-buildapps gcc make perl autoconf file g++ \
        openldap-dev libzip-dev libxml2-dev freetype-dev libpng-dev libjpeg-turbo-dev \
        dpkg-dev dpkg re2c \
    && docker-php-ext-install -j$(nproc) mysqli pdo_mysql \
    && docker-php-ext-install -j$(nproc) mbstring tokenizer fileinfo bcmath xml zip \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && apk del --purge .php-buildapps

#    && docker-php-ext-configure -j$(nproc) ldap --with-libdir=lib/x86_64-linux-gnu/ \
#    && docker-php-ext-install -j$(nproc) ldap

############## DEPENDENCIES via COMPOSER ###################
#global install of composer
RUN cd /tmp;curl -sS https://getcomposer.org/installer | php;mv /tmp/composer.phar /usr/local/bin/composer

#www-data www-data
RUN chown -R www-data:www-data /var/www/html

############ INITIAL APPLICATION SETUP #####################

WORKDIR /var/www/html
USER www-data
RUN git clone -b master https://github.com/snipe/snipe-it ./
# Get dependencies
RUN composer install && rm -rf ~/.composer/cache

############### DATA VOLUME #################

VOLUME ["/var/lib/snipeit"]


