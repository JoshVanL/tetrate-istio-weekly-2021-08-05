#!/bin/bash

kubectl create namespace istio-system

kubectl create secret generic cacerts -n istio-system \
      --from-file=ca-cert.pem \
      --from-file=ca-key.pem \
      --from-file=root-cert.pem \
      --from-file=cert-chain.pem

istioctl install --set profile=demo

kubectl get configmap istio-ca-root-cert -o yaml
