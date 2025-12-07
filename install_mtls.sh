#!/bin/bash

# Simple mTLS setup for NPM - Based on olokelo/mtls guide
# Domain: wazuh.domain.com

DOMAIN="wazuh.wincloudpms.net"

# Create certificates
mkdir -p certs && cd certs

# Generate CA
openssl ecparam -genkey -name secp256r1 | openssl ec -out ca.key
openssl req -new -x509 -days 3650 -key ca.key -out ca.pem \
    -subj "/CN=Wazuh-CA"

# Generate client certificate  
openssl ecparam -genkey -name secp256r1 | openssl ec -out client.key
openssl req -new -key client.key -out client.csr \
    -subj "/CN=wazuh-client"
openssl x509 -req -days 365 -in client.csr -CA ca.pem -CAkey ca.key -set_serial 01 -out client.crt

# Create P12 for browser import
openssl pkcs12 -export -out client.p12 \
  -inkey client.key \
  -in client.crt \
  -certfile ca.pem \
  -name "wazuh-client" \
  -passout pass:wazuh123

# Mount ca.pem to NPM container
docker cp ca.pem nginxproxy:/data/ca.pem
cp ca.pem /root/ngingxprxy/data

## NPM Advanced config 
ssl_client_certificate /data/ca.pem;
ssl_verify_client on;

echo "✅ Done! Add this to NPM Advanced config:"
echo "ssl_client_certificate /opt/ca.pem;"
echo "ssl_verify_client on;"
echo ""
echo "📱 Import client.p12 to browser (password: wazuh123)"
echo "🔧 Enable 'Force SSL' in NPM"
