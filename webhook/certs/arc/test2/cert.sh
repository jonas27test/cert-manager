#!/bin/bash
cat <<EOF | cfssl genkey - | cfssljson -bare server
{
  "hosts": [
    "webhook.webhook.svc.cluster.local",
    "10.152.183.91"
  ],
  "CN": "webhook.webhook.svc.cluster.local",
  "key": {
    "algo": "ecdsa",
    "size": 256
  }
}
EOF
<<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
  name: webhook.webhook
spec:
  request: $(cat server.csr | base64 | tr -d '\n')
  usages:
  - digital signature
  - key encipherment
  - server auth
EOF