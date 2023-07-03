output "values" {
  value       = module.software.values
  sensitive = true
}

output "hono_tls_key_in_storage" {
  value = module.software.hono_tls_key_in_storage
  sensitive = true
}

output "hono_tls_crt_in_storage" {
  value = module.software.hono_tls_crt_in_storage
  sensitive = true
}
