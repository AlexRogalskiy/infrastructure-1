#!/bin/sh

DOMAIN="$1"

/usr/bin/certbot \
    --text \
    --agree-tos \
    --no-eff-email \
    --email "{{ certbot_email }}" \
    --expand \
    --configurator certbot-external-auth:out \
    --certbot-external-auth:out-public-ip-logging-ok \
    -d "${DOMAIN}" \
    --preferred-challenges dns \
    --certbot-external-auth:out-handler /srv/dehydrated.sh \
    --certbot-external-auth:out-dehydrated-dns \
    --keep-until-expiring \
    run

if [ -z "$NO_NGINX_RESTART" ]; then
    service nginx restart
fi
