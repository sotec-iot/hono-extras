resource "google_project_service" "project" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "pubsub.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
    "iap.googleapis.com",
    "servicecontrol.googleapis.com"
  ])

  project = var.project_id
  service = each.key

  disable_on_destroy = false
}

module "networking" {
  source = "../modules/networking"

  project_id                 = var.project_id
  region                     = var.region
  ip_cidr_range              = var.ip_cidr_range
  secondary_ip_range_service = var.secondary_ip_range_services
  secondary_ip_range_pods    = var.secondary_ip_range_pods
  enable_http_ip_creation    = var.enable_http_ip_creation
  enable_mqtt_ip_creation    = var.enable_mqtt_ip_creation

  depends_on = [
    google_project_service.project
  ]
}

module "cloud_sql" {
  source = "../modules/cloud_sql"

  project_id                     = var.project_id
  region                         = var.region
  storage_size_gb                = var.storage_size_gb
  service_networking             = module.networking.service_networking
  network_id                     = module.networking.network_id
  sql_instance_name              = var.sql_instance_name
  sql_instance_version           = var.sql_instance_version
  sql_instance_machine_type      = var.sql_instance_machine_type
  sql_instance_disk_type         = var.sql_instance_disk_type
  sql_instance_deletion_policies = var.sql_instance_deletion_policies
  sql_instance_activation_policy = var.sql_instance_activation_policy
  sql_public_ip_enable           = var.sql_instance_ipv4_enable
  sql_db_user_name               = var.sql_db_user_name
  sql_database_name              = var.sql_database_name
  sql_instance_backup_enable     = var.sql_instance_backup_enable
}

module "google_iam" {
  source                       = "../modules/google_iam"
  service_name_communication   = module.cloud_endpoint.service_name_communication
  project_id                   = var.project_id
  service_account_roles_gke_sa = var.service_account_roles_gke_sa
  enable_cert_manager          = var.enable_cert_manager
}

module "gke" {
  source = "../modules/gke"

  project_id                    = var.project_id
  gke_cluster_name              = var.gke_cluster_name
  region                        = var.region
  network_name                  = module.networking.network_name
  subnetwork_name               = module.networking.subnetwork_name
  gke_release_channel           = var.gke_release_channel
  ip_ranges_services            = module.networking.ip_ranges_services_name
  ip_ranges_pods                = module.networking.ip_ranges_pods_name
  gke_service_account_email     = module.google_iam.gke_service_account_email
  gke_machine_type              = var.gke_machine_type
  gke_node_pool_name            = var.gke_node_pool_name
  node_locations                = var.node_locations
  node_pool_disk_type           = var.node_pool_disk_type
  node_pool_disk_size           = var.node_pool_disk_size
  node_pool_initial_node_count  = var.node_pool_initial_node_count
  node_pool_min_node_count      = var.node_pool_min_node_count
  node_pool_max_node_count      = var.node_pool_max_node_count
  node_pool_autoscaling_enabled = var.node_pool_autoscaling_enabled
  node_pool_upgrade_strategy    = var.node_pool_upgrade_strategy
  node_pool_max_surge           = var.node_pool_max_surge
  node_pool_max_unavailable     = var.node_pool_max_unavailable
  node_pool_batch_node_count    = var.node_pool_batch_node_count
  node_pool_batch_soak_duration = var.node_pool_batch_soak_duration
  node_pool_soak_duration       = var.node_pool_soak_duration

  depends_on = [
    google_project_service.project
  ]
}

module "pubsub" {
  source = "../modules/pubsub"

  project_id = var.project_id

  depends_on = [
    google_project_service.project
  ]
}

module "cloud_endpoint" {
  source     = "../modules/cloud_endpoint"
  project_id = var.project_id

  depends_on = [
    google_project_service.project
  ]
}
