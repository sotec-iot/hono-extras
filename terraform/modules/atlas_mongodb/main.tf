terraform {
  required_providers {
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
    }
  }
}

# Creating the Atlas MongoDB database instance
resource "mongodbatlas_project" "mongodb_project" {
  name   = var.atlas_mongodb_project_name
  org_id = var.atlas_mongodb_org_id
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%"
}

resource "mongodbatlas_database_user" "mongodb_user" {
  auth_database_name = "admin"
  project_id         = mongodbatlas_project.mongodb_project.id
  username           = "hono-user"
  password           = random_password.password.result
  roles {
    database_name = "hono-db"
    role_name     = "readWrite"
  }
}

resource "mongodbatlas_project_ip_access_list" "primary_ip" {
  project_id = mongodbatlas_project.mongodb_project.id
  cidr_block = var.gcp_subnet_ip_cidr_range
}

resource "mongodbatlas_project_ip_access_list" "secondary_ip_service" {
  project_id = mongodbatlas_project.mongodb_project.id
  cidr_block = var.gcp_subnet_secondary_ip_range_service
}

resource "mongodbatlas_project_ip_access_list" "secondary_ip_pods" {
  project_id = mongodbatlas_project.mongodb_project.id
  cidr_block = var.gcp_subnet_secondary_ip_range_pods
}

resource "mongodbatlas_network_container" "mongodb_network_container" {
  atlas_cidr_block = var.atlas_mongodb_cluster_cidr_block
  project_id       = mongodbatlas_project.mongodb_project.id
  provider_name    = "GCP"
}

resource "mongodbatlas_network_peering" "mongodb_network_peering" {
  project_id     = mongodbatlas_project.mongodb_project.id
  container_id   = mongodbatlas_network_container.mongodb_network_container.container_id
  provider_name  = "GCP"
  gcp_project_id = var.gcp_project_id
  network_name   = var.gcp_vpc_network_name
}

resource "google_compute_network_peering" "google_network_peering" {
  name         = "${var.gcp_vpc_network_name}-peering"
  network      = "projects/${var.gcp_project_id}/global/networks/${var.gcp_vpc_network_name}"
  peer_network = "https://www.googleapis.com/compute/v1/projects/${mongodbatlas_network_peering.mongodb_network_peering.atlas_gcp_project_id}/global/networks/${mongodbatlas_network_peering.mongodb_network_peering.atlas_vpc_name}"
}

resource "mongodbatlas_advanced_cluster" "mongodb_cluster" {
  cluster_type           = "REPLICASET"
  name                   = "${var.atlas_mongodb_project_name}-cluster"
  project_id             = mongodbatlas_project.mongodb_project.id
  mongo_db_major_version = var.atlas_mongodb_version
  replication_specs {
    region_configs {
      electable_specs {
        instance_size = var.atlas_mongodb_cluster_instance_size_name
        node_count    = var.atlas_mongodb_cluster_instance_node_count
      }
      priority      = 7
      provider_name = "GCP"
      region_name   = var.atlas_mongodb_region
    }
  }
  depends_on = [google_compute_network_peering.google_network_peering]
}
