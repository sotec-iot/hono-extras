resource "google_container_cluster" "hono_cluster" {
  count                    = var.gke_autopilot_enabled ? 0 : 1
  name                     = var.gke_cluster_name
  project                  = var.project_id
  location                 = var.region
  network                  = var.network_name
  subnetwork               = var.subnetwork_name
  initial_node_count       = 1
  remove_default_node_pool = true

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  private_cluster_config {
    enable_private_nodes   = var.gke_enable_private_nodes
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

  notification_config {
    pubsub {
      enabled = var.gke_notification_enabled
      topic   = "projects/${var.project_id}/topics/${var.gke_notification_pubsub_topic}"
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

resource "google_container_cluster" "hono_autopilot_cluster" {
  count      = var.gke_autopilot_enabled ? 1 : 0
  name       = var.gke_cluster_name
  project    = var.project_id
  location   = var.region
  network    = var.network_name
  subnetwork = var.subnetwork_name

  enable_autopilot = var.gke_autopilot_enabled

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

  notification_config {
    pubsub {
      enabled = var.gke_notification_enabled
      topic   = "projects/${var.project_id}/topics/${var.gke_notification_pubsub_topic}"
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

# for cluster without autopilot
resource "google_container_node_pool" "standard_node_pool" {
  count              = var.gke_autopilot_enabled ? 0 : 1
  name               = var.gke_node_pool_name
  project            = var.project_id
  location           = var.region
  cluster            = google_container_cluster.hono_cluster[0].name
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
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
  network_config {
    enable_private_nodes = var.gke_enable_private_nodes
  }
  upgrade_settings {
    strategy        = var.node_pool_upgrade_strategy
    max_surge       = var.node_pool_upgrade_strategy == "SURGE" ? var.node_pool_max_surge : null
    max_unavailable = var.node_pool_upgrade_strategy == "SURGE" ? var.node_pool_max_unavailable : null
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

resource "google_cloudfunctions2_function" "gke_notification_email_function" {
  count    = var.gke_notification_enabled ? 1 : 0
  name     = "gkeNotificationEmailSender"
  location = var.region
  lifecycle {
    precondition {
      condition     = var.sendgrid_api_key != null && var.sendgrid_api_key != "" && var.sendgrid_domain != null && var.sendgrid_domain != "" && var.gke_notification_email != null && var.gke_notification_email != ""
      error_message = "sendgrid_api_key, sendgrid_domain and gke_notification_email must be set to enable GKE notification emails."
    }
  }
  build_config {
    runtime     = "go123"
    entry_point = "SendEmail"
    source {
      storage_source {
        bucket = google_storage_bucket.gke_notification_email_function_bucket[0].name
        object = google_storage_bucket_object.gke_notification_email_function_archive[0].name
      }
    }
  }
  service_config {
    max_instance_count = 2
    environment_variables = {
      MAIL             = var.gke_notification_email
      SENDGRID_API_KEY = var.sendgrid_api_key
      SENDGRID_DOMAIN  = var.sendgrid_domain
      PROJECT_ID       = var.project_id
    }
  }
  event_trigger {
    event_type   = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = "projects/${var.project_id}/topics/${var.gke_notification_pubsub_topic}"
    retry_policy = "RETRY_POLICY_DO_NOT_RETRY"
  }
}

resource "google_storage_bucket" "gke_notification_email_function_bucket" {
  count         = var.gke_notification_enabled ? 1 : 0
  name          = "${var.project_id}-gke-notification-email-function-source"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "gke_notification_email_function_archive" {
  count  = var.gke_notification_enabled ? 1 : 0
  name   = "gke_notification_email.zip"
  bucket = google_storage_bucket.gke_notification_email_function_bucket[0].name
  source = "${path.module}/gke_notification_email.zip"
}
