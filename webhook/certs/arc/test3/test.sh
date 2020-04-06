#!/bin/bash
# https://gist.github.com/mtigas/952344

# Create a Certificate Authority root
openssl genrsa -aes256 -passout pass:joejoe -out ./ca.pass.key 4096
openssl rsa -passin pass:joejoe -in ./ca.pass.key -out ./ca.key
rm ca.pass.key

# Create the Client Key and CSR
CLIENT_ID="01-alice"
CLIENT_SERIAL=01
openssl genrsa -aes256 -passout pass:xxxx -out ${CLIENT_ID}.pass.key 4096
openssl rsa -passin pass:xxxx -in ${CLIENT_ID}.pass.key -out ${CLIENT_ID}.key
rm ${CLIENT_ID}.pass.key
openssl req -new -key ${CLIENT_ID}.key -out ${CLIENT_ID}.csr
# issue this certificate, signed by the CA root we made in the previous section
openssl x509 -req -days 3650 -in ${CLIENT_ID}.csr -CA ca.pem -CAkey ca.key -set_serial ${CLIENT_SERIAL} -out ${CLIENT_ID}.pem

# Bundle the private key & cert for end-user client use

# openssl base64 -A -in 

# cat ${CLIENT_ID}.key ${CLIENT_ID}.pem ca.pem > ${CLIENT_ID}.full.pem





openssl req -x509 -newkey rsa:2048 -keyout cer.pem -out key.pem -days 365 -nodes -subj "/CN=webhook.webhook.svc"