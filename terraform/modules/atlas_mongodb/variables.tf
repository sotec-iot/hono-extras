variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID to deploy to"
}

variable "gcp_vpc_network_name" {
  description = "Name of the GCP VPC network."
}

variable "gcp_subnet_ip_cidr_range" {
  type        = string
  description = "The range of internal addresses that are owned by the subnetwork of the VPC network."
}

variable "gcp_subnet_secondary_ip_range_service" {
  type        = string
  description = "Secondary IP Range for Services."
}

variable "gcp_subnet_secondary_ip_range_pods" {
  type        = string
  description = "Secondary IP Range for Pods."
}

variable "atlas_mongodb_org_id" {
  type        = string
  description = "Atlas Organization ID"
}

variable "atlas_mongodb_project_name" {
  type        = string
  description = "Atlas Project Name"
}

variable "atlas_mongodb_cluster_cidr_block" {
  type        = string
  description = "Cluster CIDR Block"
}

variable "atlas_mongodb_cluster_instance_size_name" {
  type        = string
  description = "Cluster instance size name"
}

variable "atlas_mongodb_cluster_instance_node_count" {
  type        = number
  description = "Cluster instance node count"
}

variable "atlas_mongodb_region" {
  type        = string
  description = "Atlas region where resources will be created"
}

variable "atlas_mongodb_version" {
  type        = string
  description = "MongoDB Version"
}

