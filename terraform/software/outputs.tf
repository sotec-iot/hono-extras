output "values" {
  value       = module.hono.values
  sensitive = true
}

output "api_tls_key_in_storage" {
  value = var.api_tls_key == null ? var.api_tls_key_from_storage : var.api_tls_key
  sensitive = true
}

output "api_tls_crt_in_storage" {
  value = var.api_tls_crt == null ? var.api_tls_crt_from_storage : var.api_tls_crt
  sensitive = true
}

output "http_tls_key_in_storage" {
  value = var.enable_http_adapter ? (var.http_tls_key == null ? var.http_tls_key_from_storage : var.http_tls_key) : null
  sensitive = true
}

output "http_tls_crt_in_storage" {
  value = var.enable_http_adapter ? (var.http_tls_crt == null ? var.http_tls_crt_from_storage : var.http_tls_crt) : null
  sensitive = true
}

output "mqtt_tls_key_in_storage" {
  value = var.enable_mqtt_adapter ? (var.mqtt_tls_key == null ? var.mqtt_tls_key_from_storage : var.mqtt_tls_key) : null
  sensitive = true
}

output "mqtt_tls_crt_in_storage" {
  value = var.enable_mqtt_adapter ? (var.mqtt_tls_crt == null ? var.mqtt_tls_crt_from_storage : var.mqtt_tls_crt) : null
  sensitive = true
}