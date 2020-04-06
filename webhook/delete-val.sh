#!/bin/bash
microk8s.kubectl delete -f val*.yaml
sleep 1
microk8s.kubectl apply -f val*.yaml
