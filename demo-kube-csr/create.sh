#!/bin/bash

helm upgrade -i --create-namespace -n cert-manager cert-manager jetstack/cert-manager --version v1.5.0-beta.0 --devel --set installCRDs=true --set featureGates="ExperimentalCertificateSigningRequestControllers=true" --wait

kubectl apply -f ./vault/vault.yaml
kubectl rollout status -n vault deployment vault
kubectl port-forward -n vault svc/vault 8200 &

export VAULT_TOKEN=root
export VAULT_ADDR='http://127.0.0.1:8200'
cd ./vault/terrform
terraform apply -auto-approve
cd -

./vault/terrform/files/k8s_auth.sh

kubectl apply -f vault/terrform/files/vault-issuer.yaml

curl http://127.0.0.1:8200/v1/pki/ca/pem -H "X-Vault-Token: root"
curl http://127.0.0.1:8200/v1/pki/ca/pem -H "X-Vault-Token: root" > root-cert.pem
kubectl create secret generic -n istio-system external-ca-cert --from-file root-cert.pem
