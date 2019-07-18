#!/bin/bash

(rm qr.txt 2> /dev/null || true) && echo "https://$(kubectl get services | grep lnd-pod | awk '{print $4}'):8080" >> qr.txt && kubectl exec lnd-pod -- xxd -p -c 250 /root/.lnd/data/chain/bitcoin/mainnet/admin.macaroon | tr -d '\n' >> qr.txt >> qr.txt && sed -i -e '$a\' qr.txt && kubectl exec lnd-pod -- cat /root/.lnd/tls.cert >> qr.txt && /usr/bin/qrencode -s 1 -m 2 -t ANSIUTF8 < qr.txt
