#!/bin/bash
# Key considerations for algorithm "RSA" ≥ 2048-bit
openssl genrsa -out server.key 2048

# Key considerations for algorithm "ECDSA" ≥ secp384r1
# List ECDSA the supported curves (openssl ecparam -list_curves)
openssl ecparam -genkey -name secp384r1 -out server.key

# Gen pub key
openssl req -new -x509 -sha256 -key server.key -out server.crt -days 3650

openssl req -x509 -newkey rsa:2048 -keyout cer.pem -out key.pem -days 365 -nodes -subj "/CN=webhook.webhook.svc"

openssl req -x509 -newkey rsa:2048 \
    -keyout key.pem \
    -out cer.pem \
    -subj "/C=US/ST=CA/O=Acme, Inc./CN=webhook.webhook.svc" \
    -reqexts SAN \
    -nodes \
    -config <(cat /etc/ssl/openssl.cnf \
        <(printf "\n[SAN]\nsubjectAltName=DNS:webhook,DNS:webhook.webhook,DNS:webhook.webhook.svc,DNS:webhook.webhook.svc.cluster.local"))

openssl x509 -in key.pem -text -noout