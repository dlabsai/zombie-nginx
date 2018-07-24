#!/bin/sh
set -e
certbot renew --post-hook "nginx -s reload" --webroot --webroot-path /var/www/letsencrypt
