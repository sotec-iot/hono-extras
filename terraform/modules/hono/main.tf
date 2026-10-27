resource "kubernetes_secret" "hono_domain_secret_tls" {
  count = var.legacy_load_balancer_setup_enabled && !var.cert_manager_enabled && ((var.hono_tls_key != null && var.hono_tls_crt != null) || (var.hono_tls_key_from_storage != null && var.hono_tls_crt_from_storage != null)) ? 1 : 0
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

resource "kubernetes_secret" "iap_client_secret" {
  count = var.legacy_load_balancer_setup_enabled ? 1 : 0

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

  lifecycle {
    precondition {
      condition     = !var.grafana_proxy_auth_enabled || (var.grafana_expose_externally && !var.legacy_load_balancer_setup_enabled)
      error_message = "grafana_proxy_auth_enabled requires grafana_expose_externally = true and legacy_load_balancer_setup_enabled = false (Grafana is only bound to loopback behind the dedicated Grafana load balancer)."
    }
  }
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
        url = "http://${var.helm_release_name}-prometheus-server.${var.hono_namespace}.svc"
      }
      rules = {
        custom = var.prometheus_adapter_custom_metrics
      }
    })
  ]
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

resource "google_project_iam_member" "gke_binding_firebase_viewer" {
  count   = var.grafana_proxy_auth_enabled ? 1 : 0
  member  = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-grafana"
  role    = "roles/firebasedatabase.viewer"
  project = var.project_id
}

moved {
  from = google_project_iam_member.gke_binding_firebase_viewer
  to   = google_project_iam_member.gke_binding_firebase_viewer[0]
}

resource "google_project_iam_member" "gke_binding_datastore_viewer" {
  count   = var.grafana_proxy_auth_enabled ? 1 : 0
  member  = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-grafana"
  role    = "roles/datastore.viewer"
  project = var.project_id
}

moved {
  from = google_project_iam_member.gke_binding_datastore_viewer
  to   = google_project_iam_member.gke_binding_datastore_viewer[0]
}

resource "google_project_iam_member" "gke_binding_secret_accessor" {
  count   = var.grafana_proxy_auth_enabled ? 1 : 0
  member  = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/${var.helm_release_name}-grafana"
  role    = "roles/secretmanager.secretAccessor"
  project = var.project_id
}

moved {
  from = google_project_iam_member.gke_binding_secret_accessor
  to   = google_project_iam_member.gke_binding_secret_accessor[0]
}

# service esp doesn't work with the newer workload identity binding method used above, therefor use workload identity impersonation
resource "google_service_account_iam_binding" "esp_workload_identity_binding" {
  count = var.legacy_load_balancer_setup_enabled ? 1 : 0

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[hono/${var.helm_release_name}-service-esp]",
  ]
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = "projects/${var.project_id}/serviceAccounts/hono-cloud-endpoint-manager@${var.project_id}.iam.gserviceaccount.com"
}
