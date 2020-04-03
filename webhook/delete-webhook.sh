#!/bin/bash
microk8s.kubectl delete -f webhook.yaml
microk8s.kubectl apply -f webhook.yaml
