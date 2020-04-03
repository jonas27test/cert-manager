#!/bin/bash
kubectl logs -n webhook $(kubectl get pods -n webhook | grep webhook |awk '{print $1}')
kubectl exec -it -n webhook $(kubectl get pods -n webhook | grep webhook |awk '{print $1}') /bin/bash
kubectl exec -it -n test $(kubectl get pods -n test | grep webhook |awk '{print $1}') /bin/bash
microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443 &
kubectl -n default exec -ti webhook -- nslookup kubernetes.default