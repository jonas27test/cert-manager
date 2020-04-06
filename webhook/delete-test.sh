#!/bin/bash
microk8s.kubectl delete -f test*.yaml
microk8s.kubectl apply -f test*.yaml
