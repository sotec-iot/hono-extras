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

resource "google_project_iam_member" "sa_binding_dns_admin" {
  count = var.legacy_load_balancer_setup_enabled ? 1 : 0

  member  = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/${var.cert_manager_namespace}/sa/cert-manager"
  role    = "roles/dns.admin"
  project = var.cert_manager_issuer_project_id != null && var.cert_manager_issuer_project_id != "" ? var.cert_manager_issuer_project_id : var.project_id
}

resource "kubectl_manifest" "issuer_letsencrypt_prod" {
  count = var.legacy_load_balancer_setup_enabled ? 1 : 0

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
  count = var.legacy_load_balancer_setup_enabled ? 1 : 0

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
  count = var.legacy_load_balancer_setup_enabled ? 1 : 0

  name             = "trust-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "trust-manager"
  version          = var.trust_manager_version
  namespace        = var.hono_namespace
  create_namespace = false
  depends_on       = [helm_release.cert-manager]
}

resource "kubectl_manifest" "trust-bundle" {
  count = var.legacy_load_balancer_setup_enabled ? 1 : 0

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

resource "kubectl_manifest" "root-issuer" {
  count = var.legacy_load_balancer_setup_enabled ? 0 : 1

  yaml_body = yamlencode({
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = var.cluster_self_signed_issuer_name
    }
    "spec" = {
      "selfSigned" = {}
    }
  })
  depends_on = [helm_release.cert-manager]
}

resource "kubectl_manifest" "root-ca-certificate" {
  count = var.legacy_load_balancer_setup_enabled ? 0 : 1

  yaml_body = yamlencode({
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = var.hono_cluster_ca_name
      "namespace" = var.cert_manager_namespace
    }
    "spec" = {
      "secretName"  = var.hono_cluster_ca_secret_name
      "duration"    = "876000h" # 100 years
      "renewBefore" = "720h"    # 30 days
      "issuerRef" = {
        "name" = var.cluster_self_signed_issuer_name
        "kind" = "ClusterIssuer"
      }
      # This certificate is a Certificate Authority
      "isCA"       = true
      "commonName" = "hono-cluster-internal-root-ca"
      "subject" = {
        "organizations" = [
          "hono"
        ]
      }
    }
  })
  depends_on = [helm_release.cert-manager, kubectl_manifest.root-issuer]
}

resource "kubectl_manifest" "ca-issuer" {
  count = var.legacy_load_balancer_setup_enabled ? 0 : 1

  yaml_body = yamlencode({
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "ClusterIssuer"
    "metadata" = {
      "name" = var.hono_cluster_ca_issuer
    }
    "spec" = {
      "ca" = {
        "secretName" : var.hono_cluster_ca_secret_name
      }
    }
  })
  depends_on = [helm_release.cert-manager, kubectl_manifest.root-ca-certificate]
}

resource "kubectl_manifest" "hono_internal_tls_cert" {
  count = var.legacy_load_balancer_setup_enabled ? 0 : 1

  yaml_body = yamlencode({
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = var.hono_internal_tls_cert_name
      "namespace" = var.hono_namespace
    }
    "spec" = {
      "secretName"  = var.hono_internal_tls_secret_name
      "duration"    = var.cert_manager_cert_duration
      "renewBefore" = var.cert_manager_cert_renew_before
      "dnsNames" = [
        "${var.helm_release_name}-adapter-http.hono.svc.cluster.local",
        "${var.helm_release_name}-adapter-mqtt.hono.svc.cluster.local",
        "${var.helm_release_name}-service-auth.hono.svc.cluster.local",
        "${var.helm_release_name}-service-command-router.hono.svc.cluster.local",
        "${var.helm_release_name}-service-device-registry.hono.svc.cluster.local"
      ]
      "subject" = {
        "organizations" = ["hono"]
      }
      "issuerRef" = {
        "name" = var.hono_cluster_ca_issuer
        "kind" = "ClusterIssuer"
      }
    }
  })
  depends_on = [kubectl_manifest.ca-issuer]
}
