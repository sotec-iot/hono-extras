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

output "sql_db_pw" {
  value       = module.cloud_sql.sql_db_pw
  sensitive   = true
  description = "Output of the SQL user password."
}

output "sql_user" {
  value       = module.cloud_sql.sql_user
  description = "Output of the SQL user name."
}

output "sql_ip" {
  value       = module.cloud_sql.sql_ip
  description = "URL of the Postgres database."
}

output "sql_hono_database" {
  value       = module.cloud_sql.sql_hono_database
  description = "Name of the hono Postgres database."
}

output "sql_grafana_database" {
  value       = module.cloud_sql.sql_grafana_database
  description = "Name of the Grafana Postgres database."
}

output "gke_autopilot_enabled" {
  value       = var.gke_autopilot_enabled
  description = "If autopilot mode is enabled for the GKE cluster."
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

output "grafana_expose_externally" {
  value       = module.networking.grafana_expose_externally
  description = "Whether or not Grafana should be exposed externally."
}
