output "gke_cluster_name" {
  value       = module.gke.gke_cluster_name
  description = "Name of the GKE cluster."
}

output "http_static_ip" {
  value       = module.networking.http_static_ip
  description = "Output of the MQTT static IP address."
}

output "mqtt_static_ip" {
  value       = module.networking.mqtt_static_ip
  description = "Output of the MQTT static IP address."
}

output "database_type" {
  value       = var.database_type
  description = "Database type. Valid values are: mongodb or postgresql"
}

output "mongodb_pw" {
  value       = module.atlas_mongodb[*].mongodb_pw
  description = "Output of the MongoDB user password."
  sensitive   = true
}

output "mongodb_user" {
  value       = module.atlas_mongodb[*].mongodb_user
  description = "Output of the MongoDB user name."
}

output "mongodb_cluster_connection_string" {
  value       = module.atlas_mongodb[*].mongodb_cluster_connection_string
  description = "Connection string for the MongoDB cluster."
}

output "sql_db_pw" {
  value       = module.cloud_sql[*].sql_db_pw
  sensitive   = true
  description = "Output of the SQL user password."
}

output "sql_user" {
  value       = module.cloud_sql[*].sql_user
  description = "Output of the SQL user name."
}

output "sql_ip" {
  value       = module.cloud_sql[*].sql_ip
  description = "URL of the Postgres database."
}

output "sql_hono_database" {
  value       = module.cloud_sql[*].sql_hono_database
  description = "Name of the hono Postgres database."
}

output "sql_grafana_database" {
  value       = module.cloud_sql[*].sql_grafana_database
  description = "Name of the Grafana Postgres database."
}

output "gke_cluster_name_endpoint" {
  value       = module.gke.gke_cluster_name_endpoint
  description = "Endpoint of the GKE cluster."
}

output "gke_cluster_ca_certificate" {
  value       = module.gke.gke_cluster_ca_certificate
  description = "CA-Certificate for the cluster."
}

output "service_name_communication" {
  value       = module.cloud_endpoint.service_name_communication
  description = "Name of the Cloud Endpoint service for device communication."
}

output "device_communication_static_ip_name" {
  value       = module.networking.device_communication_static_ip_name
  description = "Name of the static IP for external ingress."
}

output "device_communication_static_ip" {
  value       = module.networking.device_communication_static_ip
  description = "Output of the static IP for external ingress."
}

output "grafana_static_ip_name" {
  value       = module.networking.grafana_static_ip_name
  description = "Name of the static IP for Grafana external ingress."
}

output "grafana_static_ip" {
  value       = module.networking.grafana_static_ip
  description = "Output of the static IP for Grafana external ingress."
}

output "ssl_policy_name" {
  value       = module.networking.ssl_policy_name
  description = "Name of the SSL policy for external ingress."
}

output "cloud_endpoints_key_file" {
  value       = module.google_iam.cloud_endpoints_key_file
  description = "Service Account Key File for Cloud Endpoints Service Account."
  sensitive   = true
}

output "cert_manager_sa_account_id" {
  value       = module.google_iam.cert_manager_sa_account_id
  description = "Account ID of the cert-manager Service Account."
}

output "cert_manager_sa_key_file" {
  value       = module.google_iam.cert_manager_sa_key_file
  description = "Service Account Key File for cert-manager Service Account."
  sensitive   = true
}

output "cert_manager_issuer_project_id" {
  value       = module.google_iam.cert_manager_issuer_project_id
  description = "Google project ID in which the Cloud DNS zone to manage the DNS entries is located."
}

output "grafana_expose_externally" {
  value       = module.networking.grafana_expose_externally
  description = "Whether or not Grafana should be exposed externally."
}
