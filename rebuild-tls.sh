#!/bin/bash

IP=$(kubectl get services | grep lnd-pod | awk '{print $4}')
echo $IP
sed -i "s/command: \[\".\/start-lnd.sh.*/command: \[\".\/start-lnd.sh\", \"--tlsextradomain=$IP\"\]/g" pv-pod.yml
kubectl exec lnd-pod -- rm /root/.lnd/tls*
kubectl delete pod lnd-pod
