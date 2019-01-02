#!/bin/sh

# fix key if needed
if [ -z "$APP_KEY" ]
then
  echo "Please re-run this container with an environment variable \$APP_KEY"
  echo "An example APP_KEY you could use is: "
  php artisan key:generate --show
  exit
fi

# create data directories
for dir in \
  'data/private_uploads' \
  'data/uploads/accessories' \
  'data/uploads/avatars' \
  'data/uploads/barcodes' \
  'data/uploads/categories' \
  'data/uploads/companies' \
  'data/uploads/components' \
  'data/uploads/consumables' \
  'data/uploads/departments' \
  'data/uploads/locations' \
  'data/uploads/manufacturers' \
  'data/uploads/models' \
  'data/uploads/suppliers' \
  'dumps' \
  'keys'
do
  [ ! -d "/var/lib/snipeit/$dir" ] && mkdir -p "/var/lib/snipeit/$dir"
done

#chown -R www-data:www-data /var/lib/snipeit/data/* /var/lib/snipeit/dumps /var/lib/snipeit/keys

# If the Oauth DB files are not present copy the vendor files over to the db migrations
if [ ! -f "/var/www/html/database/migrations/*create_oauth*" ]
then
  cp -a /var/www/html/vendor/laravel/passport/database/migrations/* /var/www/html/database/migrations/
fi

ASSETDIR=/var/spool/snipeitassets
if [ -d "$ASSETDIR" ]
then
  echo Copy assets from /var/www/html/public
  chown -R www-data:www-data "$ASSETDIR"
  rm -rf "$ASSETDIR/*"
  cp -a /var/www/html/public/* "$ASSETDIR"
fi

docker-php-entrypoint

