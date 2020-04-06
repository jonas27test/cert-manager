#!/bin/bash

# Creating an Issuer referencing the Secret
microk8s.kubectl delete -f issuer.yaml
microk8s.kubectl apply -f issuer.yaml
# check
kubectl get clusterissuer -o wide ca-issuer

# Obtain a signed Certificate
microk8s.kubectl delete -f cert.yaml
microk8s.kubectl apply -f cert.yaml
# check
kubectl describe certificate webhook-cert -n webhook
kubectl get secret webhook-server-tls -n webhook -o yaml