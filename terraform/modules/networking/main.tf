#Creating the vpc network
resource "google_compute_network" "vpc_network" {
  project                 = var.project_id
  name                    = "hono-network"
  auto_create_subnetworks = false
}

#Creating the subnetwork
resource "google_compute_subnetwork" "subnetwork" {
  project                  = var.project_id
  region                   = var.region
  network                  = google_compute_network.vpc_network.id
  name                     = "honosubnet-01"
  ip_cidr_range            = var.ip_cidr_range
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.secondary_ip_range_service
  }
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.secondary_ip_range_pods
  }
}

resource "google_compute_router" "cloud_router" {
  count   = var.gke_enable_private_nodes ? 1 : 0
  project = var.project_id
  name    = "hono-gke-nat-router"
  region  = var.region
  network = google_compute_network.vpc_network.name
}

resource "google_compute_router_nat" "gke_nat_gateway" {
  count                              = var.gke_enable_private_nodes ? 1 : 0
  project                            = var.project_id
  name                               = "hono-gke-nat-gateway"
  region                             = var.region
  router                             = google_compute_router.cloud_router[0].name
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnetwork.name
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]
    secondary_ip_range_names = [
      "pods",
      "services"
    ]
  }

  # How external IPs are allocated for NAT.
  # "AUTO_ONLY" (default): GCP automatically allocates ephemeral external IP addresses.
  # "MANUAL_ONLY": You explicitly provide static external IP addresses.
  nat_ip_allocate_option = var.cloud_nat_ip_allocate_option

  nat_ips = var.cloud_nat_ip_allocate_option == "MANUAL_ONLY" ? var.cloud_nat_ips : []

  log_config {
    enable = var.cloud_nat_log_config.enable
    filter = var.cloud_nat_log_config.filter
  }
}

#Creating the Static IP address(external) for the http adapter
resource "google_compute_address" "http_adapter_static_ip" {
  count        = var.enable_http_ip_creation && var.legacy_load_balancer_setup_enabled ? 1 : 0
  project      = var.project_id
  region       = var.region
  name         = "http-adapter-static-ip"
  address_type = "EXTERNAL"
}

resource "google_compute_global_address" "http_adapter_static_ip" {
  count        = var.enable_http_ip_creation && !var.legacy_load_balancer_setup_enabled ? 1 : 0
  project      = var.project_id
  name         = "http-adapter-static-ip"
  address_type = "EXTERNAL"
}

#Creating the Static IP address(external) for the mqtt adapter
resource "google_compute_address" "mqtt_adapter_static_ip" {
  count        = var.enable_mqtt_ip_creation ? 1 : 0
  project      = var.project_id
  region       = var.region
  name         = "mqtt-adapter-static-ip"
  address_type = "EXTERNAL"
}

# Creating global static ip for Hono API
resource "google_compute_global_address" "hono_api_static_ip" {
  project      = var.project_id
  name         = "hono-api"
  address_type = "EXTERNAL"
}

# Creating global static ip for Grafana ingress
resource "google_compute_global_address" "grafana_static_ip" {
  count        = var.grafana_expose_externally && var.legacy_load_balancer_setup_enabled ? 1 : 0
  project      = var.project_id
  name         = "hono-grafana"
  address_type = "EXTERNAL"
}

#Creating the Private IP address for Cloud SQL instance
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
  project       = var.project_id
}

#Creating the Private VPC connection for SQL Private IP and the VPC network
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_ssl_policy" "ssl_policy" {
  name            = var.ssl_policy_name
  profile         = var.ssl_policy_profile
  min_tls_version = var.ssl_policy_min_tls_version
  project         = var.project_id
}
