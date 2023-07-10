output "gke_cluster_name" {
  value       = module.gke.gke_cluster_name
  description = "Name of the GKE Cluster"
}

output "http_static_ip" {
  value       = module.networking.http_static_ip
  description = "Output of the mqtt static ip address"
}

output "mqtt_static_ip" {
  value       = module.networking.mqtt_static_ip
  description = "Output of the mqtt static ip address"
}

output "sql_db_pw" {
  value       = module.cloud_sql.sql_db_pw
  sensitive   = true
  description = "Output of the SQL user password"
}

output "sql_user" {
  value       = module.cloud_sql.sql_user
  description = "Output of the SQL user name"
}

output "sql_ip" {
  value       = module.cloud_sql.sql_ip
  description = "URL of the Postgres Database"
}

output "sql_database" {
  value       = module.cloud_sql.sql_database
  description = "Name of the Postgres Database"
}

output "gke_cluster_name_endpoint" {
  value       = module.gke.gke_cluster_name_endpoint
  description = "Endpoint of the GKE Cluster"
}

output "gke_cluster_ca_certificate" {
  value       = module.gke.gke_cluster_ca_certificate
  description = "CA-Certificate for the Cluster"
}

output "service_name_communication" {
  value       = module.cloud_endpoint.service_name_communication
  description = "Name of the Cloud Endpoint service for device communication"
}

output "device_communication_static_ip_name" {
  value       = module.networking.device_communication_static_ip_name
  description = "Name of the Static IP for External Ingress"
}

output "device_communication_static_ip" {
  value       = module.networking.device_communication_static_ip
  description = "Output of the static IP for External Ingress"
}

output "ssl_policy_name" {
  value = module.networking.ssl_policy_name
  description = "Name of the SSL policy for external ingress"
}

output "cloud_endpoints_key_file" {
  value       = module.google_iam.cloud_endpoints_key_file
  description = "Service Account Key File for Cloud Endpoints Service Account"
  sensitive   = true
}

output "cert_manager_sa_account_id" {
  value       = module.google_iam.cert_manager_sa_account_id
  description = "Account id of the cert-manager Service Account"
}

output "cert_manager_sa_key_file" {
  value       = module.google_iam.cert_manager_sa_key_file
  description = "Service Account Key File for cert-manager Service Account"
  sensitive   = true
}
