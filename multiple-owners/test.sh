#!/bin/bash

echo "Create ns test-multi and svc test"
cat <<EOF | microk8s.kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: test-multi
---
apiVersion: v1
kind: Service
metadata:
  name: test
  namespace: test-multi
  labels:
    app: test
spec:
  selector:
    app: test
  ports:
  - port: 443
    protocol: TCP
    targetPort: 8080
EOF

echo "Create two deployments, test1-multi and test2-multi"
cat <<EOF | microk8s.kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test1-multi
  namespace: test-multi
  labels:
    app: test
spec:
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
      - name: test1-multi
        image: jonas27test/webhook:v0.0.2
        ports:
        - containerPort: 8080
          name: normal
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test2-multi
  namespace: test-multi
  labels:
    app: test
spec:
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
      - name: test1-multi
        image: jonas27test/webhook:v0.0.2
        ports:
        - containerPort: 8080
          name: normal
EOF

UID1=""
UID2=""
sleepc=0
while [ "$UID1" == "" -o "$UID2" == "" ];
do
    echo "Get UID of both deployments"
    UID1="$(microk8s.kubectl get deployment test1-multi -n test-multi -o yaml | grep uid | awk '{print $2}' )"
    UID2="$(microk8s.kubectl get deployment test2-multi -n test-multi -o yaml | grep uid | awk '{print $2}' )"
    echo "UIDs are $UID1 and $UID2"
    sleep $sleepc
    sleepc=$sleepc+2
done

echo "Create Pod"
cat <<EOF | microk8s.kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test1-slave-pod
  namespace: test-multi
  ownerReferences:
  - apiVersion: v1
    controller: true
    blockOwnerDeletion: true
    kind: Deployment
    name: test1-multi
    uid: $UID1
  - apiVersion: v1
    controller: false
    blockOwnerDeletion: true
    kind: Deployment
    name: test2-multi
    uid: $UID2
  labels:
    role: myrole
spec:
  containers:
      - name: test1-slave-pod
        image: jonas27test/webhook:v0.0.2
        ports:
        - containerPort: 8080
          name: normal
EOF
sleep 3

echo "Delete one deployment and sleep"
microk8s.kubectl delete deployment test1-multi -n test-multi
sleep 3

echo "Is pod still there?"
POD=$(microk8s.kubectl get pods -n test-multi | grep test1-slave-pod | awk '{print $2}')
echo $POD

echo "Delete other deployment and sleep"
microk8s.kubectl delete deployment test2-multi -n test-multi
sleep 3

echo "Is pod still there?"
while [ "$POD" != "" ];
do
    POD=$(microk8s.kubectl get pods -n test-multi | grep test1-slave-pod | awk '{print $1}')
    echo $POD
    sleep 3
done