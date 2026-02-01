#!/bin/bash
set -e

NPMALIAS="npm-8"
DOMAIN="host_domain"
DATE=$(date +%Y-%m-%d_%H-%M-%S)

CERT_DIR="/data/certs/$DOMAIN"
ARCHIVE_DIR="$CERT_DIR/archive"
CERT_FILE="cert.pem"
KEY_FILE="key.pem"

LIVE_CERT="/etc/letsencrypt/live/$NPMALIAS/fullchain.pem"
LIVE_KEY="/etc/letsencrypt/live/$NPMALIAS/privkey.pem"

# Optional: only run for correct renewed cert
# [[ "$RENEWED_LINEAGE" != "/etc/letsencrypt/live/$NPMALIAS" ]] && exit 0

echo "Ensuring archive directory exists"
mkdir -p "$ARCHIVE_DIR"

# Backup existing certs if they exist
if [[ -f "$CERT_DIR/$CERT_FILE" && -f "$CERT_DIR/$KEY_FILE" ]]; then
    echo "Backing up existing certs"
    cp "$CERT_DIR/$CERT_FILE" "$ARCHIVE_DIR/cert-$DATE.pem"
    cp "$CERT_DIR/$KEY_FILE"  "$ARCHIVE_DIR/key-$DATE.pem"
fi

# Update certs
echo "Updating certs"
cp "$LIVE_CERT" "$CERT_DIR/$CERT_FILE"
cp "$LIVE_KEY"  "$CERT_DIR/$KEY_FILE"

# Reload nginx
echo "Reloading nginx"
nginx -s reload

echo "Certificate update completed successfully"
