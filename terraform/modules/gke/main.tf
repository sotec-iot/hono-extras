resource "google_container_cluster" "hono_cluster" {
  name                     = var.gke_cluster_name
  project                  = var.project_id
  location                 = var.region
  network                  = var.network_name
  subnetwork               = var.subnetwork_name
  initial_node_count       = 1
  remove_default_node_pool = true

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
}
resource "google_container_node_pool" "standard_node_pool" {
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
