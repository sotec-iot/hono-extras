resource "kubernetes_secret" "hono_domain_secret_tls" {
  count = !var.cert_manager_enabled && ((var.hono_tls_key != null && var.hono_tls_crt != null) || (var.hono_tls_key_from_storage != null && var.hono_tls_crt_from_storage != null)) ? 1 : 0
  metadata {
    name      = var.hono_domain_secret_name
    namespace = var.hono_namespace
  }
  type = "kubernetes.io/tls"
  data = {
    "tls.crt" = var.hono_tls_crt == null ? var.hono_tls_crt_from_storage : var.hono_tls_crt
    "tls.key" = var.hono_tls_key == null ? var.hono_tls_key_from_storage : var.hono_tls_key
  }
}

resource "kubernetes_secret" "cloud_endpoints_key_file" {
  metadata {
    name      = "service-account-creds"
    namespace = var.hono_namespace
  }
  binary_data = {
    "hono-cloud-endpoint-manager.json" = var.cloud_endpoints_key_file
  }
}

resource "kubernetes_secret" "iap_client_secret" {
  metadata {
    name      = "iap-client-secret"
    namespace = var.hono_namespace
  }
  data = {
    "client_id"     = var.oauth_client_id
    "client_secret" = var.oauth_client_secret
  }
}

resource "helm_release" "hono" {
  name             = var.helm_release_name
  repository       = var.helm_package_repository # Repository of the hono package
  chart            = var.hono_chart_name         # name of the chart in the repository
  version          = var.hono_chart_version      # version of the chart in the repository
  namespace        = var.hono_namespace
  create_namespace = false
  timeout          = 300

  # using json to set values in the helm chart
  values = local.values
}

resource "helm_release" "prometheus_adapter" {
  count            = var.hpa_enabled ? 1 : 0
  name             = "prometheus-adapter"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "prometheus-adapter"
  namespace        = var.hono_namespace
  version          = var.prometheus_adapter_version
  create_namespace = false
  timeout          = 120

  values = [
    jsonencode({
      prometheus = {
        url = "http://eclipse-hono-prometheus-server.${var.hono_namespace}.svc"
      }
      rules = {
        custom = var.prometheus_adapter_custom_metrics
      }
    })
  ]
}
## needed to access the project number
data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_member" "gke_binding_service_account_user" {
  for_each = local.service_account_user_members
  member   = each.value
  role     = "roles/iam.serviceAccountUser"
  project  = var.project_id
}

resource "google_project_iam_member" "gke_binding_project_token_creator" {
  for_each = local.project_token_creator_members
  member   = each.value
  role     = "roles/iam.serviceAccountTokenCreator"
  project  = var.project_id
}

resource "google_project_iam_member" "gke_binding_pubsub_editor" {
  for_each = local.pubsub_editor_members
  member   = each.value
  role     = "roles/pubsub.editor"
  project  = var.project_id
}

resource "google_project_iam_member" "gke_binding_cloudtrace_agent" {
  for_each = local.cloud_trace_agent_members
  member   = each.value
  role     = "roles/cloudtrace.agent"
  project  = var.project_id
}

# service esp uses default sa, create binding & annotation
resource "kubernetes_annotations" "sa_service_esp_annotation" {
  annotations = {
    "iam.gke.io/gcp-service-account" = "gke-service-account@${var.project_id}.iam.gserviceaccount.com",
  }
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name      = "default"
    namespace = "hono"
  }
}

resource "google_service_account_iam_binding" "default_workload_identity_binding" {
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[hono/default]",
  ]
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = "projects/${var.project_id}/serviceAccounts/gke-service-account@${var.project_id}.iam.gserviceaccount.com"
}