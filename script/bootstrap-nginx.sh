#!/bin/sh

# Note: Don't set "-u" here; we might check for unset environment variables!
set -e

# Use some sensible defaults.
if [ -z "$SEAFILE_DOMAIN_NAME" ]; then
    SEAFILE_DOMAIN_NAME=127.0.0.1
fi
if [ -z "$SEAFILE_DOMAIN_PORT" ]; then
    SEAFILE_DOMAIN_PORT=80
fi

# Generate the TLS certificate for our Seafile server instance.
# SEAFILE_CERT_PATH=/etc/nginx/certs
# mkdir -p "$SEAFILE_CERT_PATH"
# openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
#    -subj "/C=US/ST=World/L=World/O=seafile/CN=$SEAFILE_DOMAIN_NAME" \
#    -keyout "$SEAFILE_CERT_PATH/seafile.key" \
#    -out "$SEAFILE_CERT_PATH/seafile.crt"
#chmod 600 "$SEAFILE_CERT_PATH/seafile.key"
#chmod 600 "$SEAFILE_CERT_PATH/seafile.crt"

# Enable Seafile in the Nginx configuration. Nginx then will serve Seafile
# over HTTPS (TLS).
ln -f -s /etc/nginx/sites-available/seafile /etc/nginx/sites-enabled/seafile
rm -f /etc/nginx/sites-enabled/default
sed -i -e "s/%SEAFILE_DOMAIN_NAME%/"$SEAFILE_DOMAIN_NAME"/g" /etc/nginx/sites-available/seafile
sed -i -e "s/%SEAFILE_DOMAIN_PORT%/"$SEAFILE_DOMAIN_PORT"/g" /etc/nginx/sites-available/seafile

# Configure Nginx so that is doesn't show its version number in the HTTP headers.
sed -i -e "s/.*server_tokens.*/server_tokens off;/g" /etc/nginx/nginx.conf
