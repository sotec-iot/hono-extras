terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1"
    }
  }
}

resource "helm_release" "cert-manager" {
  name = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  version = var.cert_manager_version
  namespace = var.cert_manager_namespace
  create_namespace = false

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_secret" "cert_manager_sa_key_secret" {
  metadata {
    name      = var.cert_manager_sa_account_id
    namespace = var.cert_manager_namespace
  }
  binary_data = {
    "key.json" = var.cert_manager_sa_key_file
  }
}

resource "kubectl_manifest" "issuer_letsencrypt_prod" {
  yaml_body = yamlencode({
    "apiVersion" = "cert-manager.io/v1"
    "kind" = var.cert_manager_issuer_kind
    "metadata" = {
      "name" = var.cert_manager_issuer_name
    }
    "spec" = {
      "acme" = {
        "email" = var.cert_manager_email
        "privateKeySecretRef" = {
          "name" = var.cert_manager_issuer_name
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "dns01" = {
              "cloudDNS" = {
                "project" = var.cert_manager_issuer_project_id
                "serviceAccountSecretRef" = {
                  "name" = var.cert_manager_sa_account_id
                  "key" = "key.json"
                }
              }
            }
          },
        ]
      }
    }
  })
  depends_on = [helm_release.cert-manager, kubernetes_secret.cert_manager_sa_key_secret]
}

resource "kubectl_manifest" "certificate" {
  yaml_body = yamlencode({
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Certificate"
    "metadata" = {
      "name" = var.hono_domain_managed_secret_name
      "namespace" = var.hono_namespace
    }
    "spec" = {
      "secretName" = var.hono_domain_managed_secret_name
      "duration" = var.cert_manager_cert_duration
      "renewBefore" = var.cert_manager_cert_renew_before
      "issuerRef" = {
        "name" = var.cert_manager_issuer_name
        "kind" = var.cert_manager_issuer_kind
      }
      "dnsNames" = [
        var.wildcard_domain,
      ]
    }
  })
  depends_on = [helm_release.cert-manager, kubernetes_secret.cert_manager_sa_key_secret]
}

resource "helm_release" "trust-manager" {
  name  = "trust-manager"
  repository = "https://charts.jetstack.io"
  chart = "trust-manager"
  version = var.trust_manager_version
  namespace = var.hono_namespace
  create_namespace = false
  depends_on = [helm_release.cert-manager]
}

resource "kubectl_manifest" "trust-bundle" {
  yaml_body = yamlencode({
    "apiVersion" = "trust.cert-manager.io/v1alpha1"
    "kind" = "Bundle"
    "metadata" = {
      "name" = var.hono_trust_store_config_map_name
    }
    "spec" = {
      "sources" = [
        {"useDefaultCAs" = true}
      ]
      "target" = {
        "configMap" = {
          "key" = "ca.crt"
        }
        "namespaceSelector" = {
          "matchLabels" = {
            "kubernetes.io/metadata.name" = "hono"
          }
        }
      }
    }
  })
  depends_on = [helm_release.trust-manager]
}