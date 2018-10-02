#!/bin/bash

IP=$(kubectl get services | grep lnd-pod | awk '{print $4}')
echo $IP
sed -i "s/command: \[\".\/start-lnd.sh.*/command: \[\".\/start-lnd.sh\", \"--tlsextradomain=$IP\"\]/g" lnd-pod.yml
kubectl exec lnd-pod -- rm /root/.lnd/tls.cert
kubectl exec lnd-pod -- rm /root/.lnd/tls.key
kubectl delete pod lnd-pod
