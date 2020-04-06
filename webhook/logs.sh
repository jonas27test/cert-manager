#!/bin/bash
microk8s.kubectl logs -n webhook $(microk8s.kubectl get pods -n webhook | grep webhook |awk '{print $1}')
microk8s.kubectl exec -it -n webhook $(microk8s.kubectl get pods -n webhook | grep webhook |awk '{print $1}') -- /bin/bash
microk8s.kubectl exec -it -n webhooktest $(microk8s.kubectl get pods -n webhooktest | grep webhooktest |awk '{print $1}') -- /bin/bash
microk8s kubectl port-forward -n kube-system service/kubernetes-dashboard 10443:443 &
kubectl -n default exec -ti -n webhook $(microk8s.kubectl get pods -n webhook | grep webhook |awk '{print $1}') -- nslookup webhook.webhookcurl