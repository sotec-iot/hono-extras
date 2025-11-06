terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1"
    }
  }
}

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_version
  namespace        = var.cert_manager_namespace
  create_namespace = false

  set {
    name  = "installCRDs"
    value = "true"
  }
  set {
    name  = "global.leaderElection.namespace"
    value = var.cert_manager_namespace
  }
}

## needed to access the project number
data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_member" "sa_binding_dns_admin" {
  member   = "principal://iam.googleapis.com/projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${var.cert_manager_namespace}/sa/cert-manager"
  role     = "roles/dns.admin"
  project  = var.cert_manager_issuer_project_id != null && var.cert_manager_issuer_project_id != "" ? var.cert_manager_issuer_project_id : var.project_id
}

resource "kubectl_manifest" "issuer_letsencrypt_prod" {
  yaml_body = yamlencode({
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = var.cert_manager_issuer_kind
    "metadata" = {
      "name" = var.cert_manager_issuer_name
    }
    "spec" = {
      "acme" = {
        "email" = var.cert_manager_email
        "privateKeySecretRef" = {
          "name" = var.cert_manager_issuer_name
        }
        # "server" = "https://acme-staging-v02.api.letsencrypt.org/directory" # use this for testing
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "dns01" = {
              "cloudDNS" = {
                "project" = var.cert_manager_issuer_project_id != null && var.cert_manager_issuer_project_id != "" ? var.cert_manager_issuer_project_id : var.project_id
              }
            }
          },
        ]
      }
    }
  })
  depends_on = [helm_release.cert-manager, google_project_iam_member.sa_binding_dns_admin]
}

resource "kubectl_manifest" "certificate" {
  yaml_body = yamlencode({
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = var.hono_domain_managed_secret_name
      "namespace" = var.hono_namespace
    }
    "spec" = {
      "secretName"  = var.hono_domain_managed_secret_name
      "duration"    = var.cert_manager_cert_duration
      "renewBefore" = var.cert_manager_cert_renew_before
      "issuerRef" = {
        "name" = var.cert_manager_issuer_name
        "kind" = var.cert_manager_issuer_kind
      }
      "dnsNames" = [
        var.hono_root_domain,
        "*.${var.hono_root_domain}",
      ]
    }
  })
  depends_on = [helm_release.cert-manager, google_project_iam_member.sa_binding_dns_admin]
}

resource "helm_release" "trust-manager" {
  name             = "trust-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "trust-manager"
  version          = var.trust_manager_version
  namespace        = var.hono_namespace
  create_namespace = false
  depends_on       = [helm_release.cert-manager]
}

resource "kubectl_manifest" "trust-bundle" {
  yaml_body = yamlencode({
    "apiVersion" = "trust.cert-manager.io/v1alpha1"
    "kind"       = "Bundle"
    "metadata" = {
      "name" = var.hono_trust_store_config_map_name
    }
    "spec" = {
      "sources" = [
        { "useDefaultCAs" = true }
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