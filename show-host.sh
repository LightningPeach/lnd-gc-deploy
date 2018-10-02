#!/bin/bash

echo https://$(kubectl get services | grep lnd-pod | awk '{print $4}'):8080
