#!/bin/bash
CMD="$1"

case $CMD in
    i-webhook)
        microk8s.kubectl apply -f webhook.yaml
        ;;

    d-webhook)
        microk8s.kubectl delete -f webhook.yaml
        ;;

    i-pod)
        microk8s.kubectl apply -f pod.yaml
        ;;

    d-pod)
        microk8s.kubectl delete -f pod.yaml
        ;;
esac