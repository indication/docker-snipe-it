FROM php:7.2-fpm-alpine

MAINTAINER in_dow <in_dow [at] hotmail.com>

################### SETUP PACKAGES  ########################
# Install recommend packages
RUN apk add -U --no-cache mysql-client vim patch git gd \
    openldap libzip freetype libpng libjpeg-turbo \
    h2o supervisor

# Setup additional packages
RUN set -ex \
    && apk add -U --no-cache --virtual .php-buildapps gcc make perl autoconf file g++ \
        openldap-dev libzip-dev libxml2-dev freetype-dev libpng-dev libjpeg-turbo-dev \
        dpkg-dev dpkg re2c \
    && docker-php-ext-install -j$(nproc) mysqli pdo_mysql \
    && docker-php-ext-install -j$(nproc) mbstring tokenizer fileinfo bcmath xml zip \
    && docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install -j$(nproc) ldap \
    && apk del --purge .php-buildapps


############## DEPENDENCIES via COMPOSER ###################
#global install of composer
RUN cd /tmp;curl -sS https://getcomposer.org/installer | php;mv /tmp/composer.phar /usr/local/bin/composer

###################### DATA VOLUME  ########################
VOLUME ["/var/lib/snipeit"]

########################## PORT ############################
EXPOSE 80

############ INITIAL APPLICATION SETUP #####################
# DO NOT change the order of following commands
WORKDIR /var/www/html
RUN chown -R www-data:www-data /var/www/html
USER www-data
RUN git clone --depth 1 -b v4.6.7 https://github.com/snipe/snipe-it ./

# Get dependencies
RUN composer global require hirak/prestissimo && composer install && rm -rf ~/.composer/cache

# Copy all configuration files
# RUN cp -a docker/*.php /var/www/html/app/config/production/
RUN cp -a docker/docker.env /var/www/html/.env

####################### SERVER SETUP #######################
USER root

# Cleanup files and create symbolic links
RUN \
        rm -r "/var/www/html/storage/private_uploads" && ln -fs "/var/lib/snipeit/data/private_uploads" "/var/www/html/storage/private_uploads" \
      && rm -rf "/var/www/html/public/uploads" && ln -fs "/var/lib/snipeit/data/uploads" "/var/www/html/public/uploads" \
      && rm -r "/var/www/html/storage/app/backups" && ln -fs "/var/lib/snipeit/dumps" "/var/www/html/storage/app/backups" \
      && mkdir "/var/lib/snipeit/keys" && ln -fs "/var/lib/snipeit/keys/oauth-private.key" "/var/www/html/storage/oauth-private.key" \
      && ln -fs "/var/lib/snipeit/keys/oauth-public.key" "/var/www/html/storage/oauth-public.key" \
      && chown www-data:www-data "/var/lib/snipeit/keys/"

# Setup H2O and supervisor
COPY supervisord.conf h2o.conf /etc/
RUN cd /etc;chmod 644 supervisord.conf h2o.conf
COPY zzz-www.conf /usr/local/etc/php-fpm.d/
RUN mkdir -p /var/run/php-fpm && chown www-data:www-data /var/run/php-fpm

# Put entry point to execute
COPY entrypoint_snipe.sh /var/www/
RUN cd /var/www;chmod +x entrypoint_snipe.sh
ENTRYPOINT ["/var/www/entrypoint_snipe.sh"]

# Startup supervisor
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
