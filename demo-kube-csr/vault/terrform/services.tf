resource "kubernetes_service_account" "vault-issuer" {
  metadata {
    name      = "vault-issuer"
    namespace = "istio-system"
  }

  automount_service_account_token = true
}


resource "vault_policy" "vault-issuer" {
  name  = "${var.issuer_name}"

  policy = <<EOT
#path "pki_int/sign/${var.issuer_name}" {
path "pki/sign/${var.issuer_name}" {
  capabilities = ["read", "update", "list", "delete"]
}

#path "pki_int/issue/${var.issuer_name}" {
path "pki/issue/${var.issuer_name}" {
  capabilities = ["read", "update", "list", "delete"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "service" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = var.issuer_name
  bound_service_account_names      = [kubernetes_service_account.vault-issuer.metadata[0].name]
  bound_service_account_namespaces = ["istio-system"]
  policies                         = [vault_policy.vault-issuer.name]
  ttl                              = 86400
}

data "template_file" "vault-issuer" {
  template = file("${path.module}/templates/vault-issuer.yaml.tpl")

  vars = {
    vault_k8s_backend_path = vault_auth_backend.kubernetes.path
    vault_k8s_role         = vault_kubernetes_auth_backend_role.service.role_name
    namespace              = "istio-system"
    vault_address          = var.vault_server
    secret_name            = kubernetes_service_account.vault-issuer.default_secret_name
  }
}

resource "local_file" "vault-issuer" {
  content  = data.template_file.vault-issuer.rendered
  filename = "${path.module}/files/vault-issuer.yaml"
}

resource "null_resource" "vault-issuer" {
  depends_on = [
    local_file.vault-issuer,
  ]

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/files/vault-issuer.yaml"
  }
}

#data "template_file" "service-cert" {
#  count    = length(var.service_names)
#  template = file("${path.module}/templates/cert.yaml.tpl")
#
#  vars = {
#    service_name = var.service_names[count.index]
#    namespace    = var.service_names[count.index]
#  }
#}

#resource "local_file" "service-cert" {
#  count    = length(var.service_names)
#  content  = data.template_file.service-cert[count.index].rendered
#  filename = "${path.module}/files/cert-${var.service_names[count.index]}.yaml"
#}
