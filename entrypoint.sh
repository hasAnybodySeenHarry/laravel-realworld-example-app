#!/bin/sh

set -e

if [ ! -f .env ] && [ -f .env.example ]; then
    echo "Creating .env from .env.example..."
    cp .env.example .env
fi

if ! grep -q '^APP_KEY=base64:' .env && [ -z "$APP_KEY" ]; then
    echo "Generating APP_KEY..."
    php artisan key:generate
fi

sed -i'' -e 's/^DB_CONNECTION=.*/DB_CONNECTION=mysql/' .env
sed -i'' -e "s/^DB_HOST=.*/DB_HOST=${DB_HOST:-mysql}/" .env
sed -i'' -e "s/^DB_PORT=.*/DB_PORT=${DB_PORT:-3306}/" .env
sed -i'' -e "s/^DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE:-laravel}/" .env
sed -i'' -e "s/^DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME:-root}/" .env
sed -i'' -e "s/^DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD:-secret}/" .env

sed -i '/^[A-Z0-9_]\+=\s*$/d' .env

echo "Waiting for MySQL..."
until php -r "new PDO('mysql:host=${DB_HOST:-mysql};port=${DB_PORT:-3306};dbname=${DB_DATABASE:-laravel}', '${DB_USERNAME:-root}', '${DB_PASSWORD:-secret}');" 2>/dev/null; do
    sleep 1
done

echo "Running migrations..."
php artisan migrate --force

echo "Caching config/routes/views..."
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Starting php-fpm..."
exec php-fpm
