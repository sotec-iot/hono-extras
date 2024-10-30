output "network_name" {
  value       = google_compute_network.vpc_network.name
  description = "Name of the network."
}

output "subnetwork_name" {
  value       = google_compute_subnetwork.subnetwork.name
  description = "Name ouf the subnetwork."
}

output "service_networking" {
  value       = google_service_networking_connection.private_vpc_connection
  description = "Output of the service networking connection for sql instance private IP and vpc network."
}

output "network_id" {
  value       = google_compute_network.vpc_network.id
  description = "Output of the network id of the network that is created."
}

output "http_static_ip" {
  value       = google_compute_address.http_static_ip[*].address
  description = "Output of the http static ip address."
}

output "mqtt_static_ip" {
  value       = google_compute_address.mqtt_static_ip[*].address
  description = "Output of the mqtt static ip address."
}

output "device_communication_static_ip_name" {
  value       = google_compute_global_address.device_communication_static_ip.name
  description = "Name of the static IP for external ingress."
}

output "device_communication_static_ip" {
  value       = google_compute_global_address.device_communication_static_ip.address
  description = "Output of the static IP for external ingress."
}

output "grafana_static_ip_name" {
  value       = google_compute_global_address.grafana_static_ip[*].name
  description = "Name of the static IP for grafana external ingress."
}

output "grafana_static_ip" {
  value       = google_compute_global_address.grafana_static_ip[*].address
  description = "Output of the static IP for grafana external ingress."
}

output "ip_ranges_services_name" {
  value = google_compute_subnetwork.subnetwork.secondary_ip_range[0].range_name
}

output "ip_ranges_pods_name" {
  value = google_compute_subnetwork.subnetwork.secondary_ip_range[1].range_name
}

output "ssl_policy_name" {
  value       = google_compute_ssl_policy.ssl_policy.name
  description = "Name of the SSL policy for external ingress."
}

output "grafana_expose_externally" {
  value       = length(google_compute_global_address.grafana_static_ip) == 1 ? true : false
  description = "Whether or not Grafana should be exposed externally."
}
