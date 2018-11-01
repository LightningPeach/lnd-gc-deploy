#!/bin/bash
IP=$(kubectl get services | grep lnd-pod | awk '{print $4}')
kubectl exec lnd-pod -- rm /root/.lnd/tls.cert
kubectl exec lnd-pod -- rm /root/.lnd/tls.key
kubectl exec lnd-pod -- cat server.json > tmp.json
sed -i "s/address/$IP/g" tmp.json
kubectl cp tmp.json lnd-pod:/server.new.json
rm tmp.json
kubectl exec lnd-pod -- sh -c 'cfssl gencert -initca server.new.json | cfssljson -bare ca -'
kubectl exec lnd-pod -- sh -c 'cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=config.json server.new.json | cfssljson -bare server'
kubectl exec lnd-pod -- sh -c 'mv /server.pem /root/.lnd/tls.cert'
kubectl exec lnd-pod -- sh -c 'mv /server-key.pem /root/.lnd/tls.key'
kubectl delete pod lnd-pod
