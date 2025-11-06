# HTTP Load-Balancer for Device Management UI, Device Registry & Device Communication API
resource "google_compute_backend_service" "management_ui_backend_service" {
  name                  = "hono-management-ui-backend-service"
  project               = var.project_id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_name             = "http"
  protocol              = "HTTP"
  timeout_sec           = 60
  health_checks         = [google_compute_health_check.management_ui_heath_check.self_link]

  log_config {
    enable        = var.gcp_load_balancer_log_config.ui.enable
    sample_rate   = var.gcp_load_balancer_log_config.ui.sample_rate
    optional_mode = var.gcp_load_balancer_log_config.ui.optional_mode
  }
  dynamic "backend" {
    for_each = [
      for zone in(var.gke_autopilot_enabled ? var.available_zones : var.node_locations) :
      {
        group = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones/${zone}/networkEndpointGroups/hono-device-management-ui-neg"
      }
    ]
    content {
      group                 = backend.value["group"]
      balancing_mode        = "RATE"
      max_rate_per_endpoint = 1000
    }
  }
  iap {
    enabled              = true
    oauth2_client_id     = var.oauth_client_id
    oauth2_client_secret = var.oauth_client_secret
  }
}

resource "google_compute_backend_service" "device_registry_backend_service" {
  name                  = "hono-device-registry-backend-service"
  project               = var.project_id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_name             = "https"
  protocol              = "HTTPS"
  timeout_sec           = 60
  health_checks         = [google_compute_health_check.device_registry_heath_check.self_link]

  log_config {
    enable        = var.gcp_load_balancer_log_config.device_registry.enable
    sample_rate   = var.gcp_load_balancer_log_config.device_registry.sample_rate
    optional_mode = var.gcp_load_balancer_log_config.device_registry.optional_mode
  }
  dynamic "backend" {
    for_each = [
      for zone in(var.gke_autopilot_enabled ? var.available_zones : var.node_locations) :
      {
        group = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones/${zone}/networkEndpointGroups/hono-device-registry-neg"
      }
    ]
    content {
      group                 = backend.value["group"]
      balancing_mode        = "RATE"
      max_rate_per_endpoint = 1000
    }
  }
  iap {
    enabled              = true
    oauth2_client_id     = var.oauth_client_id
    oauth2_client_secret = var.oauth_client_secret
  }
}

resource "google_compute_backend_service" "device_communication_backend_service" {
  name                  = "hono-device-communication-backend-service"
  project               = var.project_id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_name             = "http"
  protocol              = "HTTP"
  timeout_sec           = 60
  health_checks         = [google_compute_health_check.device_communication_heath_check.self_link]

  log_config {
    enable        = var.gcp_load_balancer_log_config.device_communication.enable
    sample_rate   = var.gcp_load_balancer_log_config.device_communication.sample_rate
    optional_mode = var.gcp_load_balancer_log_config.device_communication.optional_mode
  }
  dynamic "backend" {
    for_each = [
      for zone in(var.gke_autopilot_enabled ? var.available_zones : var.node_locations) :
      {
        group = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones/${zone}/networkEndpointGroups/hono-device-communication-neg"
      }
    ]
    content {
      group                 = backend.value["group"]
      balancing_mode        = "RATE"
      max_rate_per_endpoint = 1000
    }
  }
  iap {
    enabled              = true
    oauth2_client_id     = var.oauth_client_id
    oauth2_client_secret = var.oauth_client_secret
  }
}

resource "google_compute_backend_service" "grafana_backend_service" {
  count = var.grafana_expose_externally ? 1 : 0

  name                  = "hono-grafana-backend-service"
  project               = var.project_id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_name             = "service"
  protocol              = "HTTP"
  timeout_sec           = 60
  health_checks         = [google_compute_health_check.grafana_heath_check[0].self_link]

  log_config {
    enable        = var.gcp_load_balancer_log_config.grafana.enable
    sample_rate   = var.gcp_load_balancer_log_config.grafana.sample_rate
    optional_mode = var.gcp_load_balancer_log_config.grafana.optional_mode
  }
  dynamic "backend" {
    for_each = [
      for zone in(var.gke_autopilot_enabled ? var.available_zones : var.node_locations) :
      {
        group = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones/${zone}/networkEndpointGroups/hono-grafana-neg"
      }
    ]
    content {
      group                 = backend.value["group"]
      balancing_mode        = "RATE"
      max_rate_per_endpoint = 1000
    }
  }
  iap {
    enabled              = true
    oauth2_client_id     = var.oauth_client_id
    oauth2_client_secret = var.oauth_client_secret
  }
}

resource "google_compute_global_forwarding_rule" "hono_api_forwarding_rule" {
  name                  = "hono-api-loadbalancer"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.hono_api_proxy.id
  ip_address            = var.hono_api_static_ip
}

resource "google_compute_target_https_proxy" "hono_api_proxy" {
  name            = "hono-api-loadbalancer-proxy"
  certificate_map = "//certificatemanager.googleapis.com/projects/${var.project_id}/locations/global/certificateMaps/hono-cert-map"
  ssl_policy      = var.ssl_policy

  url_map = google_compute_url_map.hono_api_loadbalancer.self_link
}

resource "google_compute_health_check" "management_ui_heath_check" {
  name = "hono-management-ui-health-check"
  http_health_check {
    port         = "80"
    request_path = "/"
  }
}

resource "google_compute_health_check" "device_registry_heath_check" {
  name = "hono-device-registry-health-check"
  http_health_check {
    port         = "8088"
    request_path = "/"
  }
}

resource "google_compute_health_check" "device_communication_heath_check" {
  name = "hono-device-communication-health-check"
  http_health_check {
    port         = "8080"
    request_path = "/ready"
  }
}

resource "google_compute_health_check" "grafana_heath_check" {
  count = var.grafana_expose_externally ? 1 : 0

  name = "hono-grafana-health-check"
  http_health_check {
    port         = "3000"
    request_path = "/api/health"
  }
}

resource "google_compute_firewall" "hbp_hono_https_lb_device_registry" {
  project = var.project_id
  name    = "hono-api-lb"
  network = "hono-network"
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  allow {
    protocol = "tcp"
    ports    = ["8088"]
  }
  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }
  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }
}

resource "google_compute_url_map" "hono_api_loadbalancer" {
  name            = "hono-api-loadbalancer"
  default_service = google_compute_backend_service.management_ui_backend_service.self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.management_ui_backend_service.self_link

    path_rule {
      paths = [
        "/v1",
        "/v1/*"
      ]
      service = google_compute_backend_service.device_registry_backend_service.self_link
    }
    path_rule {
      paths = [
        "/v1/states/*",
        "/v1/commands/*",
        "/v1/configs/*"
      ]
      service = google_compute_backend_service.device_communication_backend_service.self_link
    }
    dynamic "path_rule" {
      for_each = var.grafana_expose_externally ? [1] : []
      content {
        paths = [
          "/grafana",
          "/grafana/*",
        ]
        service = google_compute_backend_service.grafana_backend_service[0].self_link
      }
    }
  }
}

# MQTT Load-Balancer for MQTT Adapter
resource "google_compute_global_forwarding_rule" "mqtt_adapter_forwarding_rule" {
  count = var.enable_mqtt_adapter ? 1 : 0

  name                  = "hono-mqtt-ssl-loadbalancer"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "8883"
  target                = google_compute_target_ssl_proxy.mqtt_adapter_proxy[0].id
  ip_address            = var.mqtt_adapter_static_ip
}

resource "google_compute_target_ssl_proxy" "mqtt_adapter_proxy" {
  count = var.enable_mqtt_adapter ? 1 : 0

  name            = "hono-mqtt-ssl-loadbalancer-proxy"
  backend_service = google_compute_backend_service.mqtt_adapter_backend_service[0].id
  certificate_map = "//certificatemanager.googleapis.com/projects/${var.project_id}/locations/global/certificateMaps/hono-cert-map"
  ssl_policy      = var.ssl_policy
}

resource "google_compute_security_policy" "mqtt_adapter_security_policy" {
  count = var.enable_mqtt_adapter && (var.mqtt_rate_limiting.all.enable || var.mqtt_rate_limiting.ip.enable) ? 1 : 0

  name        = "hono-mqtt-rate-limiting"
  description = "Cloud Armor policy for rate limiting the Hono MQTT traffic"
  type        = "CLOUD_ARMOR"

  dynamic "rule" {
    for_each = var.mqtt_rate_limiting.all.enable ? [1] : []
    content {
      priority    = 3000
      action      = "throttle"
      description = "rate limiting rule for all traffic"
      match {
        expr {
          expression = "true"
        }
      }
      rate_limit_options {
        enforce_on_key = "ALL"
        rate_limit_threshold {
          count        = var.mqtt_rate_limiting.all.threshold_count
          interval_sec = var.mqtt_rate_limiting.all.threshold_interval_sec
        }
        conform_action = "allow"
        exceed_action  = "deny(429)"
      }
    }
  }

  dynamic "rule" {
    for_each = var.mqtt_rate_limiting.ip.enable ? [1] : []
    content {
      priority    = 3001
      action      = "throttle"
      description = "rate limiting rule per IP"
      match {
        expr {
          expression = "true"
        }
      }
      rate_limit_options {
        enforce_on_key = "IP"
        rate_limit_threshold {
          count        = var.mqtt_rate_limiting.ip.threshold_count
          interval_sec = var.mqtt_rate_limiting.ip.threshold_interval_sec
        }
        conform_action = "allow"
        exceed_action  = "deny(429)"
      }
    }
  }

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
}

resource "google_compute_backend_service" "mqtt_adapter_backend_service" {
  count = var.enable_mqtt_adapter ? 1 : 0

  name                  = "hono-mqtt-adapter-backend-service"
  protocol              = "SSL"
  port_name             = "tcp"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = var.gcp_load_balancer_mqtt_timeout
  health_checks         = [google_compute_health_check.mqtt_adapter_health_check[0].id]
  locality_lb_policy    = "LEAST_REQUEST"
  security_policy       = var.mqtt_rate_limiting.all.enable || var.mqtt_rate_limiting.ip.enable ? google_compute_security_policy.mqtt_adapter_security_policy[0].name : null

  log_config {
    enable        = var.gcp_load_balancer_log_config.mqtt_adapter.enable
    sample_rate   = var.gcp_load_balancer_log_config.mqtt_adapter.sample_rate
    optional_mode = var.gcp_load_balancer_log_config.mqtt_adapter.optional_mode
  }
  dynamic "backend" {
    for_each = [
      for zone in(var.gke_autopilot_enabled ? var.available_zones : var.node_locations) :
      {
        group                        = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones/${zone}/networkEndpointGroups/hono-mqtt-adapter-neg"
        balancing_mode               = "CONNECTION"
        max_connections_per_endpoint = 100000
      }
    ]
    content {
      group                        = backend.value["group"]
      balancing_mode               = backend.value["balancing_mode"]
      max_connections_per_endpoint = backend.value["max_connections_per_endpoint"]
    }
  }
}

resource "google_compute_health_check" "mqtt_adapter_health_check" {
  count = var.enable_mqtt_adapter ? 1 : 0

  name               = "hono-mqtt-adapter-health-check"
  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "8883"
  }
}

resource "google_compute_firewall" "mqtt_adapter_firewall_rule" {
  count = var.enable_mqtt_adapter ? 1 : 0

  project = var.project_id
  name    = "hono-mqtt-health-check"
  network = "hono-network"
  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  allow {
    protocol = "tcp"
    ports    = ["8883"]
  }
}

# HTTP Load-Balancer for HTTP Adapter
resource "google_compute_backend_service" "http_adapter_backend_service" {
  count = var.enable_http_adapter && var.http_adapter_static_ip != "" ? 1 : 0

  name                  = "hono-http-adapter-backend-service"
  project               = var.project_id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_name             = "https"
  protocol              = "HTTPS"
  timeout_sec           = 60
  health_checks         = [google_compute_health_check.http_adapter_heath_check[0].self_link]

  log_config {
    enable        = var.gcp_load_balancer_log_config.http_adapter.enable
    sample_rate   = var.gcp_load_balancer_log_config.http_adapter.sample_rate
    optional_mode = var.gcp_load_balancer_log_config.http_adapter.optional_mode
  }
  dynamic "backend" {
    for_each = [
      for zone in(var.gke_autopilot_enabled ? var.available_zones : var.node_locations) :
      {
        group = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones/${zone}/networkEndpointGroups/hono-http-adapter-neg"
      }
    ]
    content {
      group                 = backend.value["group"]
      balancing_mode        = "RATE"
      max_rate_per_endpoint = 1000
    }
  }
  iap {
    enabled = false
  }
}

resource "google_compute_global_forwarding_rule" "http_adapter_forwarding_rule" {
  count = var.enable_http_adapter && var.http_adapter_static_ip != "" ? 1 : 0

  name                  = "hono-http-adapter-loadbalancer"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.http_adapter_proxy[0].id
  ip_address            = var.http_adapter_static_ip
}

resource "google_compute_target_https_proxy" "http_adapter_proxy" {
  count = var.enable_http_adapter && var.http_adapter_static_ip != "" ? 1 : 0

  name            = "hono-http-adapter-loadbalancer-proxy"
  certificate_map = "//certificatemanager.googleapis.com/projects/${var.project_id}/locations/global/certificateMaps/hono-cert-map"
  ssl_policy      = var.ssl_policy

  url_map = google_compute_url_map.http_adapter_loadbalancer[0].self_link
}

resource "google_compute_url_map" "http_adapter_loadbalancer" {
  count = var.enable_http_adapter && var.http_adapter_static_ip != "" ? 1 : 0

  name            = "hono-http-adapter-loadbalancer"
  default_service = google_compute_backend_service.http_adapter_backend_service[0].id
}

resource "google_compute_health_check" "http_adapter_heath_check" {
  count = var.enable_http_adapter && var.http_adapter_static_ip != "" ? 1 : 0

  name = "hono-http-adapter-health-check"
  http_health_check {
    port         = "8088"
    request_path = "/"
  }
}

# Google Certificate Manager
resource "google_certificate_manager_dns_authorization" "hono_dns_auth" {
  name        = "hono-dns-auth"
  description = "hono cert dns authorization"
  domain      = var.hono_root_domain
}

resource "google_certificate_manager_certificate_map" "hono_cert_map" {
  name = "hono-cert-map"
}

resource "google_certificate_manager_certificate" "hono_cert" {
  name        = "hono-cert"
  description = "hono cert"
  managed {
    domains = [
      var.hono_root_domain,
    ]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.hono_dns_auth.id,
    ]
  }
}

resource "google_certificate_manager_certificate_map_entry" "hono_cert_map_entry" {
  name         = "hono-entry"
  map          = google_certificate_manager_certificate_map.hono_cert_map.name
  certificates = [google_certificate_manager_certificate.hono_cert.id]
  hostname     = var.hono_root_domain
}

resource "google_certificate_manager_certificate" "hono_wildcard_cert" {
  name        = "hono-wildcard-cert"
  description = "hono wildcard cert"
  managed {
    domains = [
      "*.${var.hono_root_domain}",
    ]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.hono_dns_auth.id,
    ]
  }
}

resource "google_certificate_manager_certificate_map_entry" "hono_adapter_cert_map_entry" {
  name         = "hono-wildcard-entry"
  map          = google_certificate_manager_certificate_map.hono_cert_map.name
  certificates = [google_certificate_manager_certificate.hono_wildcard_cert.id]
  hostname     = "*.${var.hono_root_domain}"
}
