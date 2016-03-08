#!/bin/sh

echo 'Starting PHP-FPM'
php-fpm &&

echo 'Starting NGINX'
nginx &&
