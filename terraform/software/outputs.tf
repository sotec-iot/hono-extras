output "values" {
  value     = module.hono.values
  sensitive = true
}

output "hono_tls_key_in_storage" {
  value     = !var.legacy_load_balancer_setup_enabled || var.enable_cert_manager ? null : var.hono_tls_key == null ? var.hono_tls_key_from_storage : var.hono_tls_key
  sensitive = true
}

output "hono_tls_crt_in_storage" {
  value     = !var.legacy_load_balancer_setup_enabled || var.enable_cert_manager ? null : var.hono_tls_crt == null ? var.hono_tls_crt_from_storage : var.hono_tls_crt
  sensitive = true
}

output "adapter_dns_auth_resource_record" {
  value = module.gcp_load_balancer[*].adapter_dns_auth_resource_record
}
