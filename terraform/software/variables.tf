variable "hono_namespace" {
  type        = string
  description = "namespace of the deployment"
  default     = "hono"
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

variable "http_adapter_static_ip" {
  type        = string
  description = "Static ip address for the HTTP adapter loadbalancer."
}

variable "enable_mqtt_adapter" {
  type        = bool
  description = "Used to enable the mqtt adapter"
  default     = true
}

variable "mqtt_adapter_static_ip" {
  type        = string
  description = "Static ip address for the MQTT adapter loadbalancer."
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

variable "hono_api_static_ip_name" {
  type        = string
  description = "Name of the Static IP for External Ingress"
}

variable "hono_api_static_ip" {
  type        = string
  description = "Static IP for External Ingress"
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

variable "hono_api_host_address" {
  type        = string
  description = "Host address of your Hono API (e.g. api.hono.my-domain.com)"
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

variable "hono_domain_secret_name" {
  type        = string
  description = "Name of the kubernetes secret for the hono domain (wildcard)"
  default     = "hono-domain-secret"
}

variable "hono_domain_managed_secret_name" {
  type        = string
  description = "Name of the kubernetes secret for the hono domain (wildcard) in case it is managed by cert-manager"
  default     = "hono-domain-managed-secret"
}

variable "oauth_client_id" {
  type        = string
  description = "The Google OAuth 2.0 client ID used in the Identity-Aware-Proxy (IAP)"
}

variable "oauth_client_secret" {
  type        = string
  description = "The Google OAuth 2.0 client secret used in the Identity-Aware-Proxy (IAP)"
}

variable "enable_cert_manager" {
  type        = bool
  description = "Enables the use of cert manager. Only relevant if legacy_load_balancer_setup_enabled is set to true"
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
  default     = null
}

variable "cert_manager_email" {
  type        = string
  description = "E-Mail address to contact in case something goes wrong with the certificate renewal."
  default     = ""
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

variable "hono_root_domain" {
  type        = string
  description = "The root domain of the Hono installation (e.g. hono.my-domain.com)."
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

variable "cluster_self_signed_issuer_name" {
  type        = string
  description = "Name of the issuer used for the clusters internal certification process, used by cert-manager."
  default     = "selfsigned-issuer"
}

variable "hono_cluster_ca_secret_name" {
  type        = string
  description = "Name of the kubernetes secret containing the clusters internal ca.crt for hono deployments internal communication, managed by cert-manager."
  default     = "hono-cluster-ca-secret"
}

variable "hono_cluster_ca_name" {
  type        = string
  description = "Name of the clusters internal ca for hono deployments internal communication, managed by cert-manager."
  default     = "hono-cluster-ca"
}

variable "hono_cluster_ca_issuer" {
  type        = string
  description = "Name of the issuer used for the clusters application certification process, used by cert-manager."
  default     = "hono-cluster-ca-issuer"
}

variable "hono_internal_tls_cert_name" {
  type        = string
  description = "Name of the Certificate resource for Hono internal TLS"
  default     = "hono-cluster-ca-signed-eclipse-hono-all-tls-secret"
}

variable "hono_internal_tls_secret_name" {
  type        = string
  description = "Name of the kubernetes secret that will store the Hono internal TLS certificate"
  default     = "eclipse-hono-all-tls-secret"
}

variable "ssl_policy" {
  type        = string
  description = "SSL policy for external ingress."
}

variable "reloader_version" {
  type        = string
  description = "Version of the stakater reloader helm chart."
  default     = "v1.0.29"
}

variable "hpa_enabled" {
  type        = bool
  description = "Enables the creation of a horizontal pod autoscaler for the MQTT adapter and the device registry."
  default     = false
}

variable "hpa_minReplicas_mqtt" {
  type        = number
  description = "Minimum number of replicas the horizontal pod autoscaler can scale to."
  default     = 1
}

variable "hpa_maxReplicas_mqtt" {
  type        = number
  description = "Maximum number of replicas the horizontal pod autoscaler can scale to."
  default     = 10
}

variable "hpa_metrics_mqtt" {
  description = "Metrics for the MQTT horizontal pod autoscaler as JSON list."
  default = [
    {
      type = "Pods"
      pods = {
        metric = {
          name : "hono_connections_authenticated"
        }
        target = {
          type         = "AverageValue"
          averageValue = "10000"
        }
      }
    },
    {
      type = "Resource"
      resource = {
        name = "cpu"
        target = {
          type               = "Utilization"
          averageUtilization = 80
        }
      }
    },
    {
      type = "Resource"
      resource = {
        name = "memory"
        target = {
          type               = "Utilization"
          averageUtilization = 85
        }
      }
    }
  ]
}

variable "hpa_minReplicas_device_registry" {
  type        = number
  description = "Minimum number of replicas the device registry horizontal pod autoscaler can scale to."
  default     = 1
}

variable "hpa_maxReplicas_device_registry" {
  type        = number
  description = "Maximum number of replicas the device registry horizontal pod autoscaler can scale to."
  default     = 5
}

variable "prometheus_adapter_version" {
  type        = string
  description = "Version of the prometheus-adapter helm chart."
  default     = "4.4.1"
}

variable "prometheus_adapter_custom_metrics" {
  description = "Prometheus metrics to expose via the prometheus adapter to use as custom metrics in horizontal pod autoscaler."
  default = [
    {
      seriesQuery = "hono_connections_authenticated{kubernetes_namespace!=\"\",kubernetes_pod_name!=\"\"}"
      resources = {
        overrides = {
          kubernetes_namespace = { resource : "namespace" }
          kubernetes_pod_name  = { resource : "pod" }
        }
      }
      metricsQuery = "sum(hono_connections_authenticated{<<.LabelMatchers>>}) by (<<.GroupBy>>)"
    }
  ]
}

variable "grafana_expose_externally" {
  type        = bool
  description = "Whether or not Grafana should be exposed externally."
}

variable "grafana_static_ip_name" {
  type        = string
  description = "Name of the static IP for external ingress. Only relevant if both grafana_expose_externally and legacy_load_balancer_setup_enabled are set to true"
}

variable "grafana_dns_name" {
  type        = string
  description = "Name of the DNS host for Grafana. Only relevant if both grafana_expose_externally and legacy_load_balancer_setup_enabled are set to true. If Grafana is exposed with the legacy_load_balancer_setup_enabled=false it is reachable under \"https://{hono_api_host_address}/grafana\"."
  default     = ""
}

variable "helm_release_name" {
  type        = string
  description = "Name of the helm release"
  default     = "eclipse-hono"
}

variable "gke_autopilot_enabled" {
  type        = bool
  description = "If autopilot mode should be enabled for the GKE cluster."
}

variable "alerts_enabled" {
  type        = bool
  description = "If alerts should be enabled."
  default     = false
}

variable "alerts_chat_space_id" {
  type        = string
  description = "The Chat space ID is the string following “chat/space/” in the chat URL. It can only be seen in the web view of the Chat app. In order to add Google Chat as a notification channel, you must first add the Google Cloud Monitoring App to the chat space. You can add the app directly to a space by typing @Google Cloud Monitoring."
  default     = null
}

variable "data_grid_replicas" {
  type        = number
  description = "Number of replicas for the data grid"
  default     = 1
}

variable "node_locations" {
  type        = list(string)
  description = "The zones the standard node pool will create nodes in (only applicable if cluster autopilot is disabled). IMPORTANT: The GCP Load Balancer will only create Network Endpoint Groups (NEGs) in these specified zones. Pods running in other zones will not be accessible via the load balancer. This limitation does not apply to the legacy load balancer setup ('legacy_load_balancer_setup_enabled = true')."
}

variable "legacy_load_balancer_setup_enabled" {
  type        = bool
  description = "Whether the legacy load balancer setup with Kubernetes Ingress and Cloud Endpoints should be enabled."
}

variable "gcp_load_balancer_log_config" {
  type = object({
    ui = optional(object({
      enable        = optional(bool, false)
      sample_rate   = optional(number, 1.0)
      optional_mode = optional(string, "EXCLUDE_ALL_OPTIONAL")
    }), {})
    device_registry = optional(object({
      enable        = optional(bool, false)
      sample_rate   = optional(number, 1.0)
      optional_mode = optional(string, "EXCLUDE_ALL_OPTIONAL")
    }), {})
    device_communication = optional(object({
      enable        = optional(bool, false)
      sample_rate   = optional(number, 1.0)
      optional_mode = optional(string, "EXCLUDE_ALL_OPTIONAL")
    }), {})
    grafana = optional(object({
      enable        = optional(bool, false)
      sample_rate   = optional(number, 1.0)
      optional_mode = optional(string, "EXCLUDE_ALL_OPTIONAL")
    }), {})
    http_adapter = optional(object({
      enable        = optional(bool, false)
      sample_rate   = optional(number, 1.0)
      optional_mode = optional(string, "EXCLUDE_ALL_OPTIONAL")
    }), {})
  })
  description = "Logging configuration for the backend services of the GCP load balancers."
  default     = {}
}

