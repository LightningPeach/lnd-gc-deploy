# Deploy lnd to Google Cloud

To use the wallet you need deploy your own LND. 
To make it available always and everywhere, we suggest deploying it on a remote server. 

This tutorial will guide you with step-by-step instructions on how to accomplish 
this task with the help of Google cloud. 

1. Sign up for [Google cloud](https://cloud.google.com/) or sign in 
if you already have an account there. You can sign up for free and 
get $300 credit to spend on Google Cloud Platform over the next 12 months. 
To receive you need to specify your credit card details. 
Google asks you for your credit card to make sure you are not a robot. 
You won’t be charged unless you manually upgrade to a paid account.

2. Take the following steps to enable the Kubernetes Engine API:

   2.1. Visit the [Kubernetes Engine page](https://console.cloud.google.com/projectselector/kubernetes) 
   in the Google Cloud Platform Console.

   2.2. Create or select a project.

   2.3. Wait for the API and related services to be enabled. This can take several minutes.

   2.4. Make sure that [billing is enabled](https://cloud.google.com/billing/docs/how-to/modify-project) 
   for your project.

3. Go to Activate Cloud Shell (picture 1).

4. Create container cluster  
   
   ```
   gcloud container clusters create lnd-cluster --zone=europe-west1-b --num-nodes=1   
   ```
   
   It may take several minutes for the cluster to be created.

   *NOTE:* If you need a node in another zone specify desired value in the command for container cluster creation. 
   To get list with all possible zones use:

   ```
   gcloud compute zones list
   ```
 
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
   kubectl create -f lnd-service.yml
   ```

9. Create new tls certificate valid for your ip for your lnd:
  
   ```
   ./rebuild-tls.sh
   ```
  
10. Restart you lnd:
  
    ```
    kubectl create -f lnd-pod.yml
    ```

11. Get your external IP (forth column) for service lnd-pod by running: 
   
    ```
    ./show-host.sh
    ```
    You can copy and paste it as host to your signup form in the LightningPeach wallet. 
   

12. Now you need to get credentials for lnd: tls.cert and macaroons hex. To get tls.cert run:
 
    ```
    kubectl exec lnd-pod -- cat /root/.lnd/tls.cert
    ```
    To get macaroon hex run:
    ```
    kubectl exec lnd-pod -- xxd -p /root/.lnd/data/chain/bitcoin/testnet/admin.macaroon | tr -d '[:space:]'
    ```
   


Also you can deploy LND on your own from docker container. 
You will need to open ports 9735 (for peer access), 
and 8080 (for managing from a smartphone).
