# Deploy lnd to Google Cloud

To use the wallet you need deploy your own LND. 
To make it available always and everywhere, we suggest deploying it on a remote server. 
This tutorial will guide you with step-by-step instructions on how to accomplish 
this task with the help of Google cloud. 

1. Sign up for [Google cloud](https://cloud.google.com/) 
or sign in if you already have an account there. First year 
provides $300 as a trial period, which is enough for LND deploy.

2. Take the following steps to enable the 
[Kubernetes Engine API](https://console.cloud.google.com/projectselector/kubernetes?_ga=2.265124815.-1572463258.1537872403):

   2.1. Visit the Kubernetes Engine page in the Google Cloud Platform Console.

   2.2. Create or select a project.

   2.3. Wait for the API and related services to be enabled. This can take several minutes.

   2.4. Make sure that billing is enabled for your project.

3. Go to Google Cloud shell (picture 1).

4. Create container cluster 
```
gcloud container clusters create lnd-cluster --zone=europe-west1-b --num-nodes=1   
```
It may take several minutes for the cluster to be created.

5. Clone config to deploy your lnd and go to the directory:
   ```
   git clone https://github.com/LightningPeach/lnd-gc-deploy.git
   cd lnd-gc-deploy
   ```
   
5. Create volume:
   ```
   sed -i "s/volumepath/\/home\/$USER\/.lnd/g" lnd-volume.yml
   kubectl create -f lnd-volume.yml
   ```

6. Create claim:
   ```
   kubectl create -f lnd-claim.yml
   ```
   
7. Create pod:
   ```
   kubectl create -f lnd-pod.yml
   ```

8. To expose your application to traffic from the Internet, run the following command: 
   ```
   kubectl expose pod lnd-pod --port=8080 --target-port=8080 --type=LoadBalancer
   ```

9. Now you need to get credentials for lnd: tls.cert and macaroons hex. To get tls.cert run:
   ```
   kubectl exec lnd-pod -- cat /root/.lnd/tls.cert
   ```
   To get macaroon hex run:
   ```
   kubectl exec lnd-pod -- xxd -p /root/.lnd/data/chain/bitcoin/testnet/admin.macaroon
   ```
   
11. Get your external IP (third column) for service lnd-pod by running: 
   ```
   kubectl get services
   ```
   You can copy and paste it as host to your signup form in the LightningPeach wallet. 



Also you can deploy LND on your own from docker container. 
You will need to open ports 9735 (for peer access), 
and 8080 (for managing from a smartphone).
