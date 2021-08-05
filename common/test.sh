#!/bin/bash

kubectl exec "$(kubectl get pod -l app=sleep -n sandbox -o jsonpath={.items..metadata.name})" -c istio-proxy -n sandbox -- openssl s_client -showcerts -connect httpbin:8000

