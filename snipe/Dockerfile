FROM php:7.2-fpm-alpine

MAINTAINER in_dow <in_dow [at] hotmail.com>

################### SETUP PACKAGES  ########################
# Install recommend packages
RUN apk add -U --no-cache mysql-client git gd \
    openldap libzip freetype libpng libjpeg-turbo \
    h2o supervisor

# Setup additional packages
RUN set -ex \
    && apk add -U --no-cache --virtual .php-buildapps gcc make perl autoconf file g++ \
        openldap-dev libzip-dev libxml2-dev freetype-dev libpng-dev libjpeg-turbo-dev \
        dpkg-dev dpkg re2c patch \
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
ENV SNIPEIT_VERSION v4.6.9
ENV SNIPEIT_MD5SUM ccbceb632b6e26e2189e758cbc09fae1
# Clone and dependencies
# Copy all configuration files and add alias(ln) to /snipeit
RUN set -ex \
    && curl -o /tmp/snipe.tar.gz -sSL https://github.com/snipe/snipe-it/archive/$SNIPEIT_VERSION.tar.gz \
    && md5sum /tmp/snipe.tar.gz \
    && (echo "$SNIPEIT_MD5SUM */tmp/snipe.tar.gz" | md5sum -c || (md5sum /tmp/snipe.tar.gz && exit 1)) \
    && tar -xzf /tmp/snipe.tar.gz --strip-components=1 \
    && rm /tmp/snipe.tar.gz \
    && composer global require hirak/prestissimo \
    && composer install --no-dev --prefer-source \
    && rm -rf ~/.composer/cache \
    && cp -a docker/docker.env /var/www/html/.env \
    && (if [ ! -f "/var/www/html/snipeit/database/migrations/*create_oauth*" ] ; then \
        cp -a /var/www/html/snipeit/vendor/laravel/passport/database/migrations/* /var/www/html/snipeit/database/migrations/ || echo skipped ; \
       fi) \
    && ln -s . /var/www/html/public/snipeit

####################### SERVER SETUP #######################
USER root

# Cleanup files and create symbolic links
RUN set -ex \
        rm -r "/var/www/html/storage/private_uploads" && ln -fs "/var/lib/snipeit/data/private_uploads" "/var/www/html/storage/private_uploads" \
      && rm -rf "/var/www/html/public/uploads" && ln -fs "/var/lib/snipeit/data/uploads" "/var/www/html/public/uploads" \
      && rm -r "/var/www/html/storage/app/backups" && ln -fs "/var/lib/snipeit/dumps" "/var/www/html/storage/app/backups" \
      && mkdir "/var/lib/snipeit/keys" && ln -fs "/var/lib/snipeit/keys/oauth-private.key" "/var/www/html/storage/oauth-private.key" \
      && ln -fs "/var/lib/snipeit/keys/oauth-public.key" "/var/www/html/storage/oauth-public.key" \
      && chown www-data:www-data "/var/lib/snipeit/keys/"

# Setup H2O and supervisor and entrypoint
COPY supervisord.conf \
     h2o.conf \
     zzz-www.conf \
     entrypoint_snipe.sh \
     /tmp/
RUN set -ex \
      && mv /tmp/supervisord.conf /tmp/h2o.conf /etc/ \
      && chmod 644 /etc/supervisord.conf /etc/h2o.conf \
      && mv /tmp/zzz-www.conf /usr/local/etc/php-fpm.d/ \
      && mkdir -p /var/run/php-fpm \
      && chown www-data:www-data /var/run/php-fpm \
      && mv /tmp/entrypoint_snipe.sh /var/www/ \
      && chmod +x /var/www/entrypoint_snipe.sh

# Put entry point to execute
ENTRYPOINT ["/var/www/entrypoint_snipe.sh"]

ENV APP_URL http://local/snipeit
ENV APP_ENV production
ENV APP_LOG errorlog
ENV DB_CONNECTION mysql

# Startup supervisor
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
