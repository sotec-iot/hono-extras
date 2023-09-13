variable "hono_namespace" {
  type        = string
  description = "namespace of the deployment"
  default     = "hono"
}

variable "cluster_name" {
  type        = string
  description = "name of the autopilot cluster"
}

variable "project_id" {
  type        = string
  description = "Project ID in which the cluster is present"
}

variable "enable_http_adapter" {
  type        = bool
  description = "Used to enable the http adapter"
  default     = false
}

variable "enable_mqtt_adapter" {
  type        = bool
  description = "Used to enable the mqtt adapter"
  default     = true
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

variable "sql_database" {
  type        = string
  description = "name of the Postgres Database"
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
  default     = "hono"
}

variable "hono_chart_version" {
  type        = string
  description = "Version of the Chart in the Repository"
  default     = null
}

variable "oauth_app_name" {
  type        = string
  description = "Name of the Application"
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
  type = string
  description = "Name of the kubernetes secret for the hono domain (wildcard)"
  default = "hono-domain-secret"
}

variable "hono_domain_managed_secret_name" {
  type = string
  description = "Name of the kubernetes secret for the hono domain (wildcard) in case it is managed by cert-manager"
  default = "hono-domain-managed-secret"
}

variable "oauth_client_id" {
  type = string
  description = "The Google OAuth 2.0 client ID used in the Identity-Aware-Proxy (IAP)"
}

variable "oauth_client_secret" {
  type = string
  description = "The Google OAuth 2.0 client secret used in the Identity-Aware-Proxy (IAP)"
}

variable "enable_cert_manager" {
  type        = bool
  description = "Enables the use of cert manager."
  default     = false
}

variable "cert_manager_namespace" {
  type        = string
  description = "namespace of the cert manager deployment."
  default     = "cert-manager"
}

variable "cert_manager_version" {
  type        = string
  description = "Version of the chart to deploy."
  default     = "1.12.2"
}

variable "cert_manager_issuer_kind" {
  type        = string
  description = "Kind of the cert-manager issuer (Issuer or ClusterIssuer)."
  default     = "ClusterIssuer"
}

variable "cert_manager_issuer_name" {
  type        = string
  description = "Name of the cert-manager issuer."
  default     = "letsencrypt-prod"
}

variable "cert_manager_issuer_project_id" {
  type        = string
  description = "Project ID in which the Cloud DNS zone to manage the DNS entries is located."
}

variable "cert_manager_email" {
  type        = string
  description = "E-Mail address to contact in case something goes wrong with the certificate renewal."
}

variable "cert_manager_sa_account_id" {
  type        = string
  description = "Account id of the cert-manager Service Account."
}

variable "cert_manager_sa_key_file" {
  type        = string
  description = "Service Account Key File for cert-manager Service Account."
  sensitive   = true
}

variable "cert_manager_cert_duration" {
  type        = string
  description = "Validity period of a newly created certificate (e.g. 2160h for 90 day validity)."
  default     = "2160h"
}

variable "cert_manager_cert_renew_before" {
  type        = string
  description = "When to renew the certificate based on its remaining validity period (e.g. 720h for 30 days before expiration)."
  default     = "720h"
}

variable "wildcard_domain" {
  type        = string
  description = "The wildcard domain the secret will be maintained for (e.g. *.root-domain.com)."
}

variable "trust_manager_version" {
  type        = string
  description = "Version of the chart to deploy."
  default     = "0.5.0"
}

variable "hono_trust_store_config_map_name" {
  type        = string
  description = "Name of the kubernetes trust store config map for the hono deployments managed by trust-manager."
  default     = "hono-trust-store-config-map"
}

variable "ssl_policy_name" {
  type = string
  description = "Name of the SSL policy for external ingress."
}

variable "reloader_version" {
  type        = string
  description = "Version of the stakater reloader helm chart."
  default     = "v1.0.29"
}
