#!/bin/bash
microk8s.kubectl delete -f webhook.yaml
sleep 1
microk8s.kubectl apply -f webhook.yaml
