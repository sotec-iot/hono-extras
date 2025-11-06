variable "project_id" {
  type        = string
  description = "Project ID in which the cluster is present"
}

variable "available_zones" {
  type        = list(string)
  description = "Available node zone locations"
}

variable "oauth_client_id" {
  type        = string
  description = "The Google OAuth 2.0 client ID used in the Identity-Aware-Proxy (IAP)"
}

variable "oauth_client_secret" {
  type        = string
  description = "The Google OAuth 2.0 client secret used in the Identity-Aware-Proxy (IAP)"
}

variable "hono_api_static_ip" {
  type        = string
  description = "Static IP for External Ingress"
}

variable "ssl_policy" {
  type        = string
  description = "SSL policy for external ingress"
}

variable "gke_autopilot_enabled" {
  type        = bool
  description = "If autopilot mode should be enabled for the GKE cluster."
}

variable "node_locations" {
  type        = list(string)
  description = "The zones the standard node pool will create nodes in (only applicable if cluster autopilot is disabled). IMPORTANT: The GCP Load Balancer will only create Network Endpoint Groups (NEGs) in these specified zones. Pods running in other zones will not be accessible via the load balancer. This limitation does not apply to the legacy load balancer setup ('legacy_load_balancer_setup_enabled = true')."
}

variable "enable_http_adapter" {
  type        = bool
  description = "Used to enable the http adapter"
}

variable "http_adapter_static_ip" {
  type        = string
  description = "Static ip address for the HTTP adapter loadbalancer."
}

variable "enable_mqtt_adapter" {
  type        = bool
  description = "Used to enable the mqtt adapter"
}

variable "mqtt_adapter_static_ip" {
  type        = string
  description = "Static ip address for the MQTT adapter loadbalancer."
}

variable "grafana_expose_externally" {
  type        = bool
  description = "Whether or not Grafana should be exposed externally."
}

variable "hono_api_host_address" {
  type        = string
  description = "Host address of your Hono API (e.g. api.hono.my-domain.com)"
}

variable "hono_root_domain" {
  type        = string
  description = "The root domain of the Hono installation (e.g. hono.my-domain.com)."
}

variable "gcp_load_balancer_log_config" {
  type = object({
    ui = optional(object({
      enable      = optional(bool)
      sample_rate = optional(number)
      optional_mode = optional(string)
    }))
    device_registry = optional(object({
      enable      = optional(bool)
      sample_rate = optional(number)
      optional_mode = optional(string)
    }))
    device_communication = optional(object({
      enable      = optional(bool)
      sample_rate = optional(number)
      optional_mode = optional(string)
    }))
    grafana = optional(object({
      enable      = optional(bool)
      sample_rate = optional(number)
      optional_mode = optional(string)
    }))
    mqtt_adapter = optional(object({
      enable      = optional(bool)
      sample_rate = optional(number)
      optional_mode = optional(string)
    }))
    http_adapter = optional(object({
      enable        = optional(bool)
      sample_rate = optional(number)
      optional_mode = optional(string)
    }))
  })
  description = "Logging configuration for the backend services of the GCP load balancers."
}

variable "gcp_load_balancer_mqtt_timeout" {
  type = number
  description = "The timeout in seconds after which the connection will be closed by the load balancer if no communication occurred (should be longer than the keep-alive of the devices)."
}

variable "mqtt_rate_limiting" {
  type = object({
    all = optional(object({
      enable                 = optional(bool)
      threshold_count        = optional(number)
      threshold_interval_sec = optional(number)
    }), {})
    ip = optional(object({
      enable                 = optional(bool)
      threshold_count        = optional(number)
      threshold_interval_sec = optional(number)
    }), {})
  })
  description = "Rate limiting configuration for the MQTT adapter. Only one of 'all' or 'ip' can take effect. If both are specified 'all' will take precedence."
}