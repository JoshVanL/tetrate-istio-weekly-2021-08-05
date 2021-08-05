#!/bin/bash

helm upgrade -i --create-namespace -n cert-manager cert-manager jetstack/cert-manager --version v1.5.0-beta.0 --devel --set installCRDs=true --set extraArgs={--controllers='*\,-certificaterequests-approver'} --wait

kubectl apply -f https://github.com/jetstack/google-cas-issuer/releases/download/v0.5.2/google-cas-issuer-v0.5.2.yaml
kubectl apply -f k8s/base.yaml
kubectl apply -f k8s/policy-approver.yaml
kubectl apply -f policy.yaml
kubectl apply -f https://platform.jetstack.io/agent_installation.yaml
kubectl -n istio-system create secret generic googlesa --from-file $(gcloud config get-value project | tr ':' '/')-key.json
kubectl apply -f k8s/issuer.yaml
kubectl -n cert-manager create secret generic istio-ca-root-cert --from-file root-cert.pem


helm upgrade -i --create-namespace -n cert-manager cert-manager-istio-csr jetstack/cert-manager-istio-csr --wait -f ./values.yaml
