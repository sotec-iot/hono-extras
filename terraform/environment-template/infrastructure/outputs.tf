output "project_id" {
  value       = local.project_id
  description = "ID of the Project"
}

output "cluster_name" {
  value       = module.infrastructure.gke_cluster_name
  description = "Name of the GKE Cluster"
}

output "region" {
  value       = local.region
  description = "Region in which the Cluster will be deployed"
}

output "zone" {
  value       = local.zone
  description = "Zone in which the Cluster will be deployed"
}

output "http_static_ip" {
  value       = module.infrastructure.http_static_ip
  description = "Static IP for the HTTP Workload"
}

output "mqtt_static_ip" {
  value       = module.infrastructure.mqtt_static_ip
  description = "Static IP for the MQTT Workload"
}

output "database_type" {
  value       = module.infrastructure.database_type
  description = "Database type. Valid values are: mongodb or postgresql"
}

output "mongodb_pw" {
  value       = module.infrastructure.mongodb_pw
  description = "Output of the MongoDB user password."
  sensitive   = true
}

output "mongodb_user" {
  value       = module.infrastructure.mongodb_user
  description = "Output of the MongoDB user name."
}

output "mongodb_cluster_connection_string" {
  value       = module.infrastructure.mongodb_cluster_connection_string
  description = "Connection string for the MongoDB cluster."
}

output "sql_db_pw" {
  value       = module.infrastructure.sql_db_pw
  sensitive   = true
  description = "SQL Database User Password"
}

output "sql_user" {
  value       = module.infrastructure.sql_user
  description = "SQL Database Username"
}

output "sql_ip" {
  value       = module.infrastructure.sql_ip
  description = "IP of the SQL Database"
}

output "sql_hono_database" {
  value       = module.infrastructure.sql_hono_database
  description = "Name of the hono postgres database."
}

output "sql_grafana_database" {
  value       = module.infrastructure.sql_grafana_database
  description = "Name of the grafana postgres database."
}

output "service_name_communication" {
  value       = module.infrastructure.service_name_communication
  description = "Name of the Could Endpoints Service Device Registry"
}

output "device_communication_static_ip_name" {
  value       = module.infrastructure.device_communication_static_ip_name
  description = "Name of the Static IP for External Ingress"
}

output "device_communication_static_ip" {
  value       = module.infrastructure.device_communication_static_ip
  description = "Output of the static IP for External Ingress"
}

output "grafana_static_ip_name" {
  value       = module.infrastructure.grafana_static_ip_name
  description = "Name of the static IP for grafana external ingress."
}

output "grafana_static_ip" {
  value       = module.infrastructure.grafana_static_ip
  description = "Output of the static IP for grafana external ingress."
}

output "ssl_policy_name" {
  value       = module.infrastructure.ssl_policy_name
  description = "Name of the SSL policy for external ingress"
}

output "cloud_endpoints_key_file" {
  value       = module.infrastructure.cloud_endpoints_key_file
  description = "Service Account Key File for Cloud Endpoints Service Account"
  sensitive   = true
}

output "cert_manager_sa_account_id" {
  value       = module.infrastructure.cert_manager_sa_account_id
  description = "Account id of the cert-manager Service Account"
}

output "cert_manager_sa_key_file" {
  value       = module.infrastructure.cert_manager_sa_key_file
  description = "Service Account Key File for cert-manager Service Account"
  sensitive   = true
}

output "cert_manager_issuer_project_id" {
  value       = module.infrastructure.cert_manager_issuer_project_id
  description = "Project ID in which the Cloud DNS zone to manage the DNS entries is located."
}

output "grafana_expose_externally" {
  value       = module.infrastructure.grafana_expose_externally
  description = "Whether or not Grafana should be exposed externally."
}
