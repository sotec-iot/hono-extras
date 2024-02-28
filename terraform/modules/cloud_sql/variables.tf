variable "project_id" {
  type        = string
  description = "The project ID to deploy to"
}

variable "region" {
  type        = string
  description = "The region for the Cloud SQL Instance"
}

variable "storage_size_gb" {
  type        = number
  description = "The storage size in GB for the Cloud SQL Instance (100 or 200)"
}

variable "service_networking" {
  description = "Reference to service_networking connection from VPC_network to SQL Instance"
}

variable "network_id" {
  type        = string
  description = "Reference to VPC Network ID only"
}

variable "sql_instance_name" {
  type        = string
  description = "Name of the SQL Instance"
}
variable "sql_instance_version" {
  type        = string
  description = "Database Version"
}

variable "sql_instance_machine_type" {
  type        = string
  description = "Machine Type of the SQL Instance"
}

variable "sql_instance_disk_type" {
  type        = string
  description = "Disk Type of the SQL Instance"
}

variable "sql_instance_deletion_protection_enabled" {
  type        = bool
  description = "Enables the deletion protection for the SQL instance."
}

variable "sql_instance_activation_policy" {
  type        = string
  description = "This specifies when the instance should be active. Can be either ALWAYS, NEVER or ON_DEMAND."
}

variable "sql_public_ip_enable" {
  type        = bool
  description = "Whether this Cloud SQL instance should be assigned a public IPV4 address. At least ipv4_enabled must be enabled or a private_network must be configured."
}

variable "sql_db_user_name" {
  type        = string
  description = "The name of the user. Changing this forces a new resource to be created."
}

variable "sql_hono_database_name" {
  type        = string
  description = "The name of the hono database in the Cloud SQL instance. This does not include the Google project ID or instance name."
}

variable "sql_grafana_database_name" {
  type        = string
  description = "The name of the grafana database in the Cloud SQL instance. This does not include the Google project ID or instance name."
}

variable "sql_instance_backup_enabled" {
  type        = bool
  description = "Whether this Cloud SQL instance should enable automatic backups."
}

variable "sql_instance_backup_location" {
  type        = string
  description = "Location where the Cloud SQL instance backups are stored."
}

variable "sql_instance_backup_start_time" {
  type        = string
  description = "The time at which the Cloud SQL instance should start the daily backup."
}

variable "sql_instance_backup_count" {
  type        = number
  description = "The number of backups the Cloud SQL instance should retain."
}

variable "sql_instance_maintenance_window" {
  type = object({
    day          = number,
    hour         = number,
    update_track = string
  })
  description = "The maintenance window settings for the cloud sql instance. For details see: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance"
}
