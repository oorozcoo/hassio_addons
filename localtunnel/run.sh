#!/bin/bash
set -e

# Set Variables
CONFIG_PATH="/data/options.json"
DOMAIN=$(jq --raw-output ".domain" $CONFIG_PATH)
SUBDOMAIN=$(jq --raw-output ".subdomain" $CONFIG_PATH)
PORT=$(jq --raw-output ".port" $CONFIG_PATH)

echo "[INFO] Starting"
echo "[INFO] Validating requirements"

#Valida si ya existe localtunnel
if [ -d ../localtunnel/ ]; then
        echo "Starting tunnel..."
        lt --host http://${DOMAIN} --secure --subdomain=${SUBDOMAIN} --port ${PORT} &
        TUNEL=`lt --host http://${DOMAIN} --secure --subdomain=${SUBDOMAIN} --port ${PORT}`
        echo $TUNEL
else

echo "[ADD] Downloading localtunnel"
git clone https://github.com/localtunnel/localtunnel.git

echo "[INFO] Entering to localtunnel folder"
cd localtunnel

echo "[INFO] Installing localtunnel"
npm install -g localtunnel

echo "[INFO] Starting tunnel"
        lt --host http://${DOMAIN} --secure --subdomain=${SUBDOMAIN} --port ${PORT} &
        TUNEL=`lt --host http://${DOMAIN} --secure --subdomain=${SUBDOMAIN} --port ${PORT}`
        echo $TUNEL
fi
