#!/bin/bash

echo ">> istioctl x uninstall -y --purge"
istioctl x uninstall -y --purge

echo ">> kubectl delete namespace istio-system"
kubectl delete namespace istio-system
