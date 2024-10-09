resource "google_container_cluster" "hono_cluster" {
  name                     = var.gke_cluster_name
  project                  = var.project_id
  location                 = var.region
  network                  = var.network_name
  subnetwork               = var.subnetwork_name

  enable_autopilot         = var.gke_autopilot_enabled

  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = var.gke_service_account_email
    }
  }

  release_channel {
    channel = var.gke_release_channel
  }

  ip_allocation_policy {
    services_secondary_range_name = var.ip_ranges_services
    cluster_secondary_range_name  = var.ip_ranges_pods
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
  }

  dynamic "maintenance_policy" {
    for_each = var.gke_cluster_maintenance_policy_recurring_window != null ? [1] : []
    content {
      recurring_window {
        start_time = var.gke_cluster_maintenance_policy_recurring_window.start_time
        end_time   = var.gke_cluster_maintenance_policy_recurring_window.end_time
        recurrence = var.gke_cluster_maintenance_policy_recurring_window.recurrence
      }
    }
  }
}



# Autopilot-cluster
resource "google_project_iam_member" "gke_k8_binding_pubsub_editor" {
  count = var.gke_autopilot_enabled ? 1 : 0
  member             = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/default"
  project = var.project_id
  role               = "roles/pubsub.editor"
}
resource "google_project_iam_member" "gke_k8_binding_cloudtrace_agent" {
  count = var.gke_autopilot_enabled ? 1 : 0
  member             = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/default"
  project = var.project_id
  role               = "roles/cloudtrace.agent"
}
resource "google_project_iam_member" "gke_k8_binding_instance_user" {
  count = var.gke_autopilot_enabled ? 1 : 0
  member             = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/default"
  project = var.project_id
  role               = "roles/cloudsql.instanceUser"
}
resource "google_project_iam_member" "gke_k8_binding_cloudsql_client" {
  count = var.gke_autopilot_enabled ? 1 : 0
  member             = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/default"
  project = var.project_id
  role               = "roles/cloudsql.client"
}
resource "google_project_iam_member" "gke_k8_binding_cloudsql_instanceuser" {
  count = var.gke_autopilot_enabled ? 1 : 0
  member             = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/default"
  project = var.project_id
  role               = "roles/cloudsql.instanceUser"
}
resource "google_project_iam_member" "gke_k8_binding_servicemanagement_servicecontroller" {
  count = var.gke_autopilot_enabled ? 1 : 0
  member             = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/hono/sa/default"
  project = var.project_id
  role               = "roles/servicemanagement.serviceController"
}


# Standard-cluster
resource "google_container_node_pool" "standard_node_pool" {
  count = var.gke_autopilot_enabled ? 0 : 1
  name               = var.gke_node_pool_name
  project            = var.project_id
  location           = var.region
  cluster            = google_container_cluster.hono_cluster.name
  initial_node_count = var.node_pool_initial_node_count
  node_locations     = var.node_locations
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  dynamic "autoscaling" {
    for_each = var.node_pool_autoscaling_enabled ? [1] : []
    content {
      min_node_count = var.node_pool_min_node_count
      max_node_count = var.node_pool_max_node_count
    }
  }
  node_config {
    machine_type    = var.gke_machine_type
    local_ssd_count = 0
    disk_size_gb    = var.node_pool_disk_size
    disk_type       = var.node_pool_disk_type
    image_type      = "COS_CONTAINERD"
    preemptible     = false

    service_account = var.gke_service_account_email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  upgrade_settings {
    strategy        = var.node_pool_upgrade_strategy
    max_surge       = var.node_pool_upgrade_strategy == "SURGE"? var.node_pool_max_surge : null
    max_unavailable = var.node_pool_upgrade_strategy == "SURGE"? var.node_pool_max_unavailable : null
    dynamic "blue_green_settings" {
      for_each = var.node_pool_upgrade_strategy != "SURGE" ? [1] : []
      content {
        standard_rollout_policy {
          batch_node_count    = var.node_pool_batch_node_count
          batch_soak_duration = var.node_pool_batch_soak_duration
        }
        node_pool_soak_duration = var.node_pool_soak_duration
      }
    }
  }
}
