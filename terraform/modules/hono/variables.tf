variable "hono_namespace" {
  type        = string
  description = "namespace of the hono deployment"
}

variable "cluster_name" {
  type        = string
  description = "name of the cluster"
}

variable "project_id" {
  type        = string
  description = "Project ID in which the cluster is present"
}

variable "enable_http_adapter" {
  type        = bool
  description = "Used to enable the http adapter"
}

variable "enable_mqtt_adapter" {
  type        = bool
  description = "Used to enable the mqtt adapter"
}

variable "cert_manager_enabled" {
  type        = bool
  description = "Disables the creation of TLS secrets to manually maintain"
}

variable "http_static_ip" {
  type        = string
  description = "static ip address for the http loadbalancer"
}

variable "mqtt_static_ip" {
  type        = string
  description = "static ip address for the mqtt loadbalancer"
}

variable "sql_user" {
  type        = string
  description = "username of the sql database username"
}

variable "sql_db_pw" {
  type        = string
  sensitive   = true
  description = "password for the sql_user for the database"
}

variable "sql_ip" {
  type        = string
  description = "URL of the Postgres Database"
}

variable "sql_hono_database" {
  type        = string
  description = "Name of the postgres database for Hono."
}

variable "sql_grafana_database" {
  type        = string
  description = "Name of the postgres database for Grafana."
}

variable "service_name_communication" {
  type        = string
  description = "name of the Cloud Endpoint service for device communication"
}

variable "device_communication_static_ip_name" {
  type        = string
  description = "Name of the Static IP for External Ingress"
}

variable "helm_package_repository" {
  type        = string
  description = "Link to the Helm Package for the Hono Deployment"
}

variable "hono_chart_name" {
  type        = string
  description = "Name of the Chart in the Repository"
}

variable "hono_chart_version" {
  type        = string
  description = "Version of the Chart in the Repository"
}

variable "oauth_app_name" {
  type        = string
  description = "Name of the OAuth Application"
}

variable "device_communication_dns_name" {
  type        = string
  description = "Name of the DNS Host"
}

variable "hono_tls_key" {
  type        = string
  description = "Content of the hono domain tls Key File"
}

variable "hono_tls_crt" {
  type        = string
  description = "Content of the hono domain tls Cert File"
}

variable "hono_tls_key_from_storage" {
  type        = string
  description = "Content of the hono domain tls Key File from storage bucket"
}

variable "hono_tls_crt_from_storage" {
  type        = string
  description = "Content of the hono domain tls Cert File from storage bucket"
}

variable "cloud_endpoints_key_file" {
  type        = string
  description = "Service Account Key File for Cloud Endpoints Service Account"
  sensitive   = true
}

variable "hono_domain_secret_name" {
  type        = string
  description = "Name of the kubernetes secret for the hono domain (wildcard)"
}

variable "hono_domain_managed_secret_name" {
  type        = string
  description = "Name of the kubernetes secret for the hono domain (wildcard) in case it is managed by cert-manager"
}

variable "hono_trust_store_config_map_name" {
  type        = string
  description = "Name of the kubernetes trust store config map for the hono deployments managed by trust-manager."
}

variable "oauth_client_id" {
  type        = string
  description = "The Google OAuth 2.0 client ID used in the Identity-Aware-Proxy (IAP)"
}

variable "oauth_client_secret" {
  type        = string
  description = "The Google OAuth 2.0 client secret used in the Identity-Aware-Proxy (IAP)"
}

variable "ssl_policy_name" {
  type        = string
  description = "Name of the SSL policy for external ingress"
}

variable "hpa_enabled" {
  type        = bool
  description = "Enables the creation of horizontal pod autoscaler for the MQTT adapter and the device registry."
}

variable "hpa_minReplicas_mqtt" {
  type        = number
  description = "Minimum number of replicas that the horizontal pod autoscaler must maintain for the MQTT adapter deployment."
}

variable "hpa_maxReplicas_mqtt" {
  type        = number
  description = "Maximum number of replicas that the horizontal pod autoscaler can spawn for the MQTT adapter deployment."
}

variable "hpa_metrics_mqtt" {
  description = "Metrics for the MQTT horizontal pod autoscaler as JSON list."
}

variable "hpa_minReplicas_device_registry" {
  type        = number
  description = "Minimum number of replicas that the horizontal pod autoscaler must maintain for the device registry deployment."
}

variable "hpa_maxReplicas_device_registry" {
  type        = number
  description = "Maximum number of replicas that the horizontal pod autoscaler can spawn for the device registry deployment."
}

variable "prometheus_adapter_version" {
  type        = string
  description = "Version of the prometheus-adapter helm chart."
}

variable "prometheus_adapter_custom_metrics" {
  description = "Prometheus metrics to expose via the prometheus adapter to use as custom metrics in horizontal pod autoscaler."
}

variable "grafana_expose_externally" {
  type        = bool
  description = "Whether or not Grafana should be exposed externally."
}

variable "grafana_static_ip_name" {
  type        = string
  description = "Name of the static IP for external ingress."
}

variable "grafana_dns_name" {
  type        = string
  description = "Name of the DNS host for Grafana"
}
