#!/bin/bash

IP=$(kubectl get services | grep lnd-pod | awk '{print $4}')
# echo $IP
# sed -i "s/command: \[\".\/start-lnd.sh.*/command: \[\".\/start-lnd.sh\", \"--tlsextraip=$IP\"\]/g" lnd-pod.yml
kubectl exec lnd-pod -- rm /root/.lnd/tls.cert
kubectl exec lnd-pod -- rm /root/.lnd/tls.key
kubectl exec lnd-pod -- gencerts -H $IP -H 0.0.0.0 -d /root/.lnd/
kubectl exec lnd-pod -- mv /root/.lnd/rpc.cert /root/.lnd/tls.cert
kubectl exec lnd-pod -- mv /root/.lnd/rpc.key /root/.lnd/tls.key
kubectl delete pod lnd-pod
