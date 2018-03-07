#!/bin/sh

set -e

python3 /opt/appconf.py /etc/appconf/nginx.yml > /etc/nginx/nginx.conf

configure_letsencrypt() {
  if [[ -z "${LETSENCRYPT_EMAIL}" ]] ; then
    echo "Please set LETSENCRYPT_EMAIL when using Let's Encrypt"
    exit 1
  fi
  if [ ! -e /etc/letsencrypt ] ; then
      ln -s /etc/nginx/certs/ /etc/letsencrypt
  fi
  if ! ls -1A /etc/letsencrypt/live/ | grep -q . ; then
    mkdir -p /var/www/letsencrypt
    certbot certonly -n --standalone --webroot-path /var/www/letsencrypt --agree-tos --email ${LETSENCRYPT_EMAIL} -d $1
  fi
  crontab /etc/cron.d/cert_renew
  crond
}

if [ -e /tmp/le-domain.txt ] ; then
  DOMAIN=`cat /tmp/le-domain.txt`
  configure_letsencrypt ${DOMAIN}
fi

exec "$@"
