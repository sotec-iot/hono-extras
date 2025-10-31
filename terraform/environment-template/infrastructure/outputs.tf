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

output "node_locations" {
  value       = local.node_locations
  description = "The zones the standard node pool will create nodes in (only applicable if cluster autopilot is disabled). IMPORTANT: The GCP Load Balancer will only create Network Endpoint Groups (NEGs) in these specified zones. Pods running in other zones will not be accessible via the load balancer. This limitation does not apply to the legacy load balancer setup ('legacy_load_balancer_setup_enabled = true')."
}

output "http_adapter_static_ip" {
  value       = module.infrastructure.http_adapter_static_ip
  description = "Output of the http adapter static ip address."
}

output "mqtt_adapter_static_ip" {
  value       = module.infrastructure.mqtt_adapter_static_ip
  description = "Output of the mqtt adapter static ip address."
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

output "gke_autopilot_enabled" {
  value       = module.infrastructure.gke_autopilot_enabled
  description = "If autopilot mode is enabled for the GKE cluster."
}

output "service_name_communication" {
  value       = module.infrastructure.service_name_communication
  description = "Name of the Cloud Endpoints Service Device Registry"
}

output "hono_api_static_ip_name" {
  value       = module.infrastructure.hono_api_static_ip_name
  description = "Name of the Static IP for External Ingress"
}

output "hono_api_static_ip" {
  value       = module.infrastructure.hono_api_static_ip
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

output "ssl_policy" {
  value       = module.infrastructure.ssl_policy
  description = "SSL policy for external ingress"
}

output "grafana_expose_externally" {
  value       = module.infrastructure.grafana_expose_externally
  description = "Whether or not Grafana should be exposed externally."
}

output "legacy_load_balancer_setup_enabled" {
  value       = module.infrastructure.legacy_load_balancer_setup_enabled
  description = "Whether the legacy load balancer setup with Kubernetes Ingress and Cloud Endpoints should be enabled."
}
