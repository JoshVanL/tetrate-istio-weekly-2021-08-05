apiVersion: v1
kind: Namespace
metadata:
  name: ${namespace}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${service_name}
  namespace: ${service_name}
spec:
  duration: 10h
  renewBefore: 5h
  secretName: ${service_name}-tls
  dnsNames:
  - ${service_name}.${service_name}
  usages:
    - server auth
  issuerRef:
    name: vault
    kind: Issuer
    group: cert-manager.io
