#!/bin/sh

set -e

rm -f /tmp/le-domain.txt
python3 /opt/appconf.py /etc/appconf/nginx.yml > /etc/nginx/nginx.conf

configure_letsencrypt() {
  if [ -z "${LETSENCRYPT_EMAIL}" ] ; then
    echo "Please set LETSENCRYPT_EMAIL when using Let's Encrypt"
    exit 1
  fi
  if [ ! -e /etc/letsencrypt ] ; then
      ln -s /etc/nginx/certs/ /etc/letsencrypt
  fi
  while read line; do
    FIRST_DOMAIN=$(echo "$line" | cut -f2 -d " ")
    DOMAINS=$line
    if [ ! -d /etc/letsencrypt/live/${FIRST_DOMAIN} ] ; then
      certbot certonly -n --standalone --webroot-path /var/www/letsencrypt --agree-tos --email "${LETSENCRYPT_EMAIL}" ${DOMAINS}
    fi
  done < /tmp/le-domain.txt
  crontab /etc/cron.d/cert_renew
  crond
}

if [ -e /tmp/le-domain.txt ] ; then
  configure_letsencrypt
fi

exec "$@"
