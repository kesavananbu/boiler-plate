#!/bin/bash
NPMALIAS="npm-8"
DOMAIN="host_domain"
dateF=$(date +%Y-%m)
certFile=cert
keyFile=key

#Check if correct renewed cert
#[[ $RENEWED_LINEAGE != "/etc/letsencrypt/live/$NPMALIAS" ]] && exit 0

#Backup existing certs
echo "Backing up certs"
if [ -f /data/certs/$DOMAIN/$certFile.pem ]; then
    #Check if certs exist
    if [ ! -f /data/certs/$DOMAIN/archive/ ]; then
        echo "Creating path structure"
        mkdir -p /data/certs/$DOMAIN/archive/
        touch /data/certs/$DOMAIN/$certFile.pem
        touch /data/certs/$DOMAIN/$keyFile.pem
    fi
fi

#Update certs
echo "Updating certs"
cat /etc/letsencrypt/live/$NPMALIAS/fullchain.pem > /data/certs/$DOMAIN/$certFile.pem
cat /etc/letsencrypt/live/$NPMALIAS/privkey.pem > /data/certs/$DOMAIN/$keyFile.pem

#Reload nginx configuration
nginx -s reload
