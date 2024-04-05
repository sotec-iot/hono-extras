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

variable "http_static_ip" {
  type        = string
  description = "static ip address for the http loadbalancer"
}

variable "mqtt_static_ip" {
  type        = string
  description = "static ip address for the mqtt loadbalancer"
}

variable "database_type" {
  type        = string
  description = "Database type. Valid values are: mongodb or postgresql"
}

variable "mongodb_pw" {
  type        = string
  description = "Password of the MongoDB user."
}

variable "mongodb_user" {
  type        = string
  description = "User name of the MongoDB user."
}

variable "mongodb_cluster_connection_string" {
  type        = string
  description = "Connection string for the MongoDB cluster."
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
  type        = string
  description = "Name of the SSL policy for external ingress."
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
  default     = [
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
  default     = [
    {
      seriesQuery = "hono_connections_authenticated{kubernetes_namespace!=\"\",kubernetes_pod_name!=\"\"}"
      resources = {
        overrides = {
          kubernetes_namespace = { resource : "namespace" }
          kubernetes_pod_name = { resource : "pod" }
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
  description = "Name of the static IP for external ingress."
}

variable "grafana_dns_name" {
  type        = string
  description = "Name of the DNS host for Grafana"
  default     = ""
}

variable "mqtt_adapter" {
  type = object({
    enabled                = optional(bool, true),
    advanced_load_balancer = optional(object({
      enabled       = optional(bool, false),
      chart_version = optional(string, "1.34.1"),
      algorithm     = optional(string, "leastconn"),
      replicaCount  = optional(number, 1),
      resources     = optional(object({
        limits = optional(object({
          cpu    = optional(string, null),
          memory = optional(string, null)
        }), {}),
        requests = optional(object({
          cpu    = optional(string, "500m"),
          memory = optional(string, "1000Mi")
        }), {})
      }), {}),
      port_configs = optional(list(object({
        name       = string,
        port       = number,
        targetPort = optional(number, 8883)
      })), [
        {
          name : "mqtt"
          port : 8883
          targetPort : 8883
        }
      ]),
      tcp_configmap_data = optional(map(string), {
        8883 = "hono/eclipse-hono-adapter-mqtt:8883"
      })
    }), {}),
  })
  description = <<EOT
Configuration options for the MQTT adapter.
  enabled: Enables the MQTT adapter.
  advanced_load_balancer:
    enabled: Enables the use of the advanced MQTT load balancer.
    chart_version: Version of the chart to deploy.
    algorithm: Load balancing algorithm used by the advanced MQTT load balancer. For a list of possible options see https://www.haproxy.com/documentation/kubernetes-ingress/community/configuration-reference/ingress/#load-balance .
    replicaCount: Number of replicas to deploy.
    resources: Resource requests and limits.
    port_configs: List of MQTT port config objects for the advanced MQTT load balancer service.
    tcp_configmap_data: Data of the TCP configMap for the advanced MQTT load balancer.
EOT
  default = {}
}
