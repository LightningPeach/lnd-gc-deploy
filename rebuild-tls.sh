#!/bin/bash

IP=$(kubectl get services | grep lnd-pod | awk '{print $4}')
# echo $IP
# sed -i "s/command: \[\".\/start-lnd.sh.*/command: \[\".\/start-lnd.sh\", \"--tlsextraip=$IP\"\]/g" lnd-pod.yml
kubectl exec lnd-pod -- rm /root/.lnd/tls.cert
kubectl exec lnd-pod -- rm /root/.lnd/tls.key
kubectl exec lnd-pod -- sh -c 'sed -i "s/address/\"$IP\",/g" /server.json'
# sed -i "s/address/\"$IP\",/g" tmp.json
# DATA=$(cat tmp.json)
# kubectl exec lnd-pod -- $DATA >> server.json
kubectl exec lnd-pod -- cfssl gencert -initca server.json | cfssljson -bare ca -
kubectl exec lnd-pod -- cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=config.json server.json | cfssljson -bare server
kubectl exec lnd-pod -- mv /root/.lnd/server.pem /root/.lnd/tls.cert
kubectl exec lnd-pod -- mv /root/.lnd/server-key.pem /root/.lnd/tls.key
kubectl delete pod lnd-pod
