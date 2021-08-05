#!/bin/bash

istioctl install --set profile=demo

kubectl get configmap istio-ca-root-cert -o yaml
