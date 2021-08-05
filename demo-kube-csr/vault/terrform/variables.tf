variable "vault_server" {
  description = "Address for Vault"
  default     = "vault.vault:8200"
}

variable "k8s_host" {
  description = "Address for Kubernetes"
  #default     = "127.0.0.1:43775"
  #default     = "10.96.0.1"
  default     = "34.142.76.24"
}

variable "issuer_name" {
  default     = "istio-ca"
}
