output "adapter_dns_auth_resource_record" {
  value = google_certificate_manager_dns_authorization.hono_dns_auth.dns_resource_record
}

output "grafana_dns_auth_resource_record" {
  value = google_certificate_manager_dns_authorization.grafana_dns_auth[*].dns_resource_record
}
