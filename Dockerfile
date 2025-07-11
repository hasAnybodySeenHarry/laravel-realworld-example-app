FROM php:8.3-fpm-alpine AS build

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

RUN composer install -q --no-ansi --no-interaction --no-progress --no-dev --prefer-dist --optimize-autoloader

FROM php:8.3-fpm-alpine

RUN docker-php-ext-install pdo_mysql

WORKDIR /var/www

COPY --from=build /var/www /var/www

RUN mkdir -p storage bootstrap/cache \
 && chown -R www-data:www-data /var/www \
 && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER www-data

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
