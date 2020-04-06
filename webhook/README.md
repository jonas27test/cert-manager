# cert-manager
Create a (Cluster-) Issuer to Issue certificates for either ns or cluster.
- Cluster Issuer is accisble for every ns
- Issuer is accesible only in same nsk
The Certificate is then stored in a


Use microk8s registry
docker build . -t localhost:32000/mynginx:registry