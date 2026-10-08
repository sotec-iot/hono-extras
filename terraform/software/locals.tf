locals {
  hono_root_domain_labels = split(".", var.hono_root_domain)
  root_domain = coalesce(
    var.root_domain,
    length(local.hono_root_domain_labels) > 2 ? join(".", slice(local.hono_root_domain_labels, 1, length(local.hono_root_domain_labels))) : var.hono_root_domain
  )
  grafana_dns_name = var.grafana_dns_name != "" ? var.grafana_dns_name : "grafana.${local.root_domain}"
}
