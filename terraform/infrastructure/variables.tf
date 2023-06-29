variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "region" {
  description = "The region to deploy to"
  type        = string
  default     = "europe-west1"
}

variable "ip_cidr_range" {
  type        = string
  description = "The range of internal addresses that are owned by this subnetwork. Provide this property when you create the subnetwork.Ranges must be unique and non-overlapping within a network. Only IPv4 is supported."
  default     = "10.10.1.0/24"
}

variable "secondary_ip_range_services" {
  type        = string
  description = "Secondary IP Ranges in Subnetwork for Services"
  default     = "10.10.11.0/24"
}

variable "secondary_ip_range_pods" {
  type        = string
  description = "Secondary IP Ranges in Subnetwork for Pods"
  default     = "10.1.0.0/20"
}

variable "enable_http_ip_creation" {
  type        = string
  description = "Used to enable the creation of a static ip for the http adapter"
  default     = false
}

variable "enable_mqtt_ip_creation" {
  type        = string
  description = "Used to enable the creation of a static ip for the mqtt adapter"
  default     = true
}

variable "gke_machine_type" {
  type        = string
  description = "Machine Type for node_pools"
  default     = "c2-standard-8"
}

variable "gke_cluster_name" {
  type        = string
  description = "Name of the GKE Cluster"
  default     = "hono-cluster"
}

variable "sql_instance_name" {
  type        = string
  description = "Name of the SQL Instance"
  default     = "hono-sql"
}

variable "sql_instance_version" {
  type        = string
  description = "Database Version"
  default     = "POSTGRES_14"
}

variable "sql_instance_deletion_policies" {
  type        = bool
  description = "Used to block Terraform from deleting a SQL Instance. Defaults to false."
  default     = true
}

variable "sql_instance_machine_type" {
  type        = string
  description = "Machine Type of the SQL Instance"
  default     = "db-custom-1-3840"
}

variable "sql_instance_disk_type" {
  type        = string
  description = "Disk Type of the SQL Instance"
  default     = "PD-SSD"
}

variable "sql_instance_activation_policy" {
  type        = string
  description = "This specifies when the instance should be active. Can be either ALWAYS, NEVER or ON_DEMAND."
  default     = "ALWAYS"
}

variable "sql_instance_ipv4_enable" {
  type        = bool
  description = "Whether this Cloud SQL instance should be assigned a public IPV4 address. At least ipv4_enabled must be enabled or a private_network must be configured."
  default     = false
}

variable "sql_db_user_name" {
  type        = string
  description = "The name of the user. Changing this forces a new resource to be created."
  default     = "hono-user"
}

variable "sql_database_name" {
  type        = string
  description = "The name of the database in the Cloud SQL instance. This does not include the project ID or instance name."
  default     = "hono-db"
}

variable "service_account_roles_gke_sa" {
  description = "Additional roles to be added to the GKE service account."
  type        = list(string)
  default     = []
}

variable "gke_release_channel" {
  type        = string
  description = "Which Release Channel to use for the Cluster"
  default     = "STABLE"
}

variable "node_pool_disk_type" {
  type        = string
  default     = "pd-standard"
}

variable "node_pool_disk_size" {
  type        = number
  description = "Size of the Node Pool Disk"
  default     = 50
}

variable "node_pool_initial_node_count" {
  type        = number
  description = "Initial number of nodes"
  default     = 1
}

variable "node_pool_min_node_count" {
  type        = number
  description = "minimum number of nodes per zone"
  default     = 0
}

variable "node_pool_max_node_count" {
  type        = number
  description = "maximum number of nodes per zone"
  default     = 3
}

variable "storage_size_gb" {
  type        = number
  description = "The storage size in GB for the Cloud SQL Instance (100 or 200)"
  default     = 100
}

variable "gke_node_pool_name" {
  type        = string
  description = "The name of the Node Pool in the Hono Cluster"
  default     = "standard-node-pool"
}

variable "node_locations" {
  type        = list(string)
  description = "List of Strings for the Node Locations"
}

variable "node_pool_autoscaling_enabled" {
  type        = string
  description = "If node autoscaling should be enabled"
  default     = false
}

variable "node_pool_upgrade_strategy" {
  type        = string
  description = "Upgrade strategy for node pool"
  default     = "SURGE"
}

variable "node_pool_max_surge" {
  type        = number
  description = "Max surge nodes during surge upgrade process"
  default     = 1
}

variable "node_pool_max_unavailable" {
  type        = number
  description = "Max unavailable nodes during surge upgrade process"
  default     = 0
}

variable "node_pool_batch_node_count" {
  type        = number
  description = "Number of nodes to drain in a batch during blue-green upgrade process"
  default     = 1
}

variable "node_pool_batch_soak_duration" {
  type        = string
  description = "Duration to wait after each batch finishes draining during blue-green upgrade process"
  default     = "0s"
}

variable "node_pool_soak_duration" {
  type        = string
  description = "Duration to wait after all batches are drained during blue-green upgrade process"
  default     = "3600s"
}

variable "sql_instance_backup_enable" {
  type        = bool
  description = "Whether this Cloud SQL instance should enable automatic backups"
  default     = false
}
