output "values" {
  value       = module.software.values
  sensitive = true
}

output "api_tls_key_in_storage" {
  value = module.software.api_tls_key_in_storage
  sensitive = true
}

output "api_tls_crt_in_storage" {
  value = module.software.api_tls_crt_in_storage
  sensitive = true
}

output "http_tls_key_in_storage" {
  value = module.software.http_tls_key_in_storage
  sensitive = true
}

output "http_tls_crt_in_storage" {
  value = module.software.http_tls_crt_in_storage
  sensitive = true
}

output "mqtt_tls_key_in_storage" {
  value = module.software.mqtt_tls_key_in_storage
  sensitive = true
}

output "mqtt_tls_crt_in_storage" {
  value = module.software.mqtt_tls_crt_in_storage
  sensitive = true
}
