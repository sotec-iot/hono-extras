variable "project_id" {
  type        = string
  description = "The project ID to deploy to"
}

variable "gke_cluster_name" {
  type        = string
  description = "Name of the GKE Cluster"
}

variable "gke_cluster_maintenance_policy_recurring_window" {
  type = object({
    start_time = string,
    end_time = string,
    recurrence = string
  })
  description = "The recurring window maintenance policy for the cluster. For details see: https://registry.terraform.io/providers/hashicorp/google/5.15.0/docs/resources/container_cluster#nested_maintenance_policy"
}

variable "region" {
  type        = string
  description = "The region to deploy to"
}

variable "network_name" {
  type        = string
  description = "name of the network"
}

variable "subnetwork_name" {
  type        = string
  description = "name of the subnetwork"
}

variable "gke_autopilot_enabled" {
  type        = bool
  description = "If autopilot mode should be enabled for the GKE cluster."
}

variable "gke_release_channel" {
  type        = string
  description = "Which Release Channel to use for the Cluster"
}

variable "ip_ranges_services" {
  type        = string
  description = "Secondary IP Ranges in Subnetwork for Services"
}

variable "ip_ranges_pods" {
  type        = string
  description = "Secondary IP Ranges in Subnetwork for Pods"
}

variable "gke_service_account_email" {
  type        = string
  description = "Email of the GKE Service Account"
}

variable "gke_machine_type" {
  type        = string
  description = "Machine Type for node_pools"
}

variable "gke_node_pool_name" {
  type        = string
  description = "The name of the Node Pool in the Hono Cluster"
}

variable "node_locations" {
  type        = list(string)
  description = "List of Strings for the Node Locations"
}

variable "node_pool_disk_type" {
  type        = string
  description = "Disk type of the Node Pool"
}

variable "node_pool_disk_size" {
  type        = number
  description = "Size of the Node Pool Disk"
}

variable "node_pool_initial_node_count" {
  type        = number
  description = "Initial number of nodes"
}

variable "node_pool_min_node_count" {
  type        = number
  description = "Minimum number of nodes per zone"
}

variable "node_pool_max_node_count" {
  type        = number
  description = "Maximum number of nodes per zone"
}

variable "node_pool_autoscaling_enabled" {
  type        = string
  description = "If node autoscaling should be enabled"
}

variable "node_pool_upgrade_strategy" {
  type        = string
  description = "Upgrade strategy for node pool"
}

variable "node_pool_max_surge" {
  type        = number
  description = "Max surge nodes during surge upgrade process"
}

variable "node_pool_max_unavailable" {
  type        = number
  description = "Max unavailable nodes during surge upgrade process"
}

variable "node_pool_batch_node_count" {
  type        = number
  description = "Number of nodes to drain in a batch during blue-green upgrade process"
}

variable "node_pool_batch_soak_duration" {
  type        = string
  description = "Duration to wait after each batch finishes draining during blue-green upgrade process"
}

variable "node_pool_soak_duration" {
  type        = string
  description = "Duration to wait after all batches are drained during blue-green upgrade process"
}