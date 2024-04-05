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
  ssl_policy_name            = var.ssl_policy_name
  ssl_policy_profile         = var.ssl_policy_profile
  ssl_policy_min_tls_version = var.ssl_policy_min_tls_version
  grafana_expose_externally  = var.grafana_expose_externally

  depends_on = [
    google_project_service.project
  ]
}

module "atlas_mongodb" {
  source = "../modules/atlas_mongodb"
  count  = var.database_type == "mongodb" ? 1 : 0

  gcp_project_id                            = var.project_id
  gcp_vpc_network_name                      = module.networking.network_name
  gcp_subnet_ip_cidr_range                  = var.ip_cidr_range
  gcp_subnet_secondary_ip_range_service     = var.secondary_ip_range_services
  gcp_subnet_secondary_ip_range_pods        = var.secondary_ip_range_pods
  atlas_mongodb_org_id                      = var.atlas_mongodb_org_id
  atlas_mongodb_project_name                = var.atlas_mongodb_project_name
  atlas_mongodb_region                      = var.atlas_mongodb_region
  atlas_mongodb_cluster_cidr_block          = var.atlas_mongodb_cluster_cidr_block
  atlas_mongodb_cluster_instance_size_name  = var.atlas_mongodb_cluster_instance_size_name
  atlas_mongodb_cluster_instance_node_count = var.atlas_mongodb_cluster_instance_node_count
  atlas_mongodb_version                     = var.atlas_mongodb_version

  depends_on = [module.networking]
}

module "cloud_sql" {
  source = "../modules/cloud_sql"
  count  = var.database_type == "postgresql" ? 1 : 0

  project_id                               = var.project_id
  region                                   = var.region
  storage_size_gb                          = var.storage_size_gb
  service_networking                       = module.networking.service_networking
  network_id                               = module.networking.network_id
  sql_instance_name                        = var.sql_instance_name
  sql_instance_version                     = var.sql_instance_version
  sql_instance_machine_type                = var.sql_instance_machine_type
  sql_instance_disk_type                   = var.sql_instance_disk_type
  sql_instance_deletion_protection_enabled = var.sql_instance_deletion_protection_enabled
  sql_instance_activation_policy           = var.sql_instance_activation_policy
  sql_instance_maintenance_window          = var.sql_instance_maintenance_window
  sql_public_ip_enable                     = var.sql_instance_ipv4_enable
  sql_db_user_name                         = var.sql_db_user_name
  sql_hono_database_name                   = var.sql_hono_database_name
  sql_grafana_database_name                = var.sql_grafana_database_name
  sql_instance_backup_enabled              = var.sql_instance_backup_enabled
  sql_instance_backup_location             = var.sql_instance_backup_location
  sql_instance_backup_start_time           = var.sql_instance_backup_start_time
  sql_instance_backup_count                = var.sql_instance_backup_count
}

module "google_iam" {
  source                         = "../modules/google_iam"
  service_name_communication     = module.cloud_endpoint.service_name_communication
  project_id                     = var.project_id
  service_account_roles_gke_sa   = var.service_account_roles_gke_sa
  enable_cert_manager            = var.enable_cert_manager
  cert_manager_sa_account_id     = var.cert_manager_sa_account_id
  cert_manager_issuer_project_id = var.cert_manager_issuer_project_id
}

module "gke" {
  source = "../modules/gke"

  project_id                                      = var.project_id
  gke_cluster_name                                = var.gke_cluster_name
  gke_cluster_maintenance_policy_recurring_window = var.gke_cluster_maintenance_policy_recurring_window
  region                                          = var.region
  network_name                                    = module.networking.network_name
  subnetwork_name                                 = module.networking.subnetwork_name
  gke_release_channel                             = var.gke_release_channel
  ip_ranges_services                              = module.networking.ip_ranges_services_name
  ip_ranges_pods                                  = module.networking.ip_ranges_pods_name
  gke_service_account_email                       = module.google_iam.gke_service_account_email
  gke_machine_type                                = var.gke_machine_type
  gke_node_pool_name                              = var.gke_node_pool_name
  node_locations                                  = var.node_locations
  node_pool_disk_type                             = var.node_pool_disk_type
  node_pool_disk_size                             = var.node_pool_disk_size
  node_pool_initial_node_count                    = var.node_pool_initial_node_count
  node_pool_min_node_count                        = var.node_pool_min_node_count
  node_pool_max_node_count                        = var.node_pool_max_node_count
  node_pool_autoscaling_enabled                   = var.node_pool_autoscaling_enabled
  node_pool_upgrade_strategy                      = var.node_pool_upgrade_strategy
  node_pool_max_surge                             = var.node_pool_max_surge
  node_pool_max_unavailable                       = var.node_pool_max_unavailable
  node_pool_batch_node_count                      = var.node_pool_batch_node_count
  node_pool_batch_soak_duration                   = var.node_pool_batch_soak_duration
  node_pool_soak_duration                         = var.node_pool_soak_duration

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
