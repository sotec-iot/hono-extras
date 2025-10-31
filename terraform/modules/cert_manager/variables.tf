variable "project_id" {
  type        = string
  description = "Project ID in which the cluster is present"
}

variable "project_number" {
  type        = string
  description = "Project number of the project in which the cluster is present"
}

variable "helm_release_name" {
  type        = string
  description = "Name of the helm release"
}

variable "hono_namespace" {
  type        = string
  description = "Namespace of the hono deployment."
}

variable "cert_manager_namespace" {
  type        = string
  description = "Namespace of the cert manager deployment."
}

variable "cert_manager_version" {
  type        = string
  description = "Version of the chart to deploy."
}

variable "trust_manager_version" {
  type        = string
  description = "Version of the chart to deploy."
}

variable "cert_manager_issuer_kind" {
  type        = string
  description = "Kind of the cert-manager issuer (Issuer or ClusterIssuer)."
}

variable "cert_manager_issuer_name" {
  type        = string
  description = "Name of the cert-manager issuer."
}

variable "cert_manager_issuer_project_id" {
  type        = string
  description = "Project ID in which the Cloud DNS zone to manage the DNS entries is located."
}

variable "cert_manager_email" {
  type        = string
  description = "E-Mail address to contact in case something goes wrong with the certificate renewal."
}

variable "hono_domain_managed_secret_name" {
  type        = string
  description = "Name of the kubernetes secret for the hono domain (wildcard) managed by cert-manager."
}

variable "cert_manager_cert_duration" {
  type        = string
  description = "Validity period of a newly created certificate (e.g. 2160h for 90 day validity)."
}

variable "cert_manager_cert_renew_before" {
  type        = string
  description = "When to renew the certificate based on its remaining validity period (e.g. 720h for 30 days before expiration)."
}

variable "hono_root_domain" {
  type        = string
  description = "The root domain of the Hono installation (e.g. hono.my-domain.com)."
}

variable "hono_trust_store_config_map_name" {
  type        = string
  description = "Name of the kubernetes trust store config map for the hono deployments managed by trust-manager."
}

variable "cluster_self_signed_issuer_name" {
  type        = string
  description = "Name of the issuer used for the clusters root internal certification process, used by cert-manager."
}

variable "hono_cluster_ca_secret_name" {
  type        = string
  description = "Name of the kubernetes secret containing the clusters internal ca.crt for hono deployments internal communication, managed by cert-manager."
}

variable "hono_cluster_ca_name" {
  type        = string
  description = "Name of the clusters internal ca for hono deployments internal communication, managed by cert-manager."
}

variable "hono_cluster_ca_issuer" {
  type        = string
  description = "Name of the issuer used for the clusters application certification process, used by cert-manager."
}

variable "hono_internal_tls_cert_name" {
  type        = string
  description = "Name of the Certificate resource for Hono internal TLS"
}

variable "hono_internal_tls_secret_name" {
  type        = string
  description = "Name of the kubernetes secret that will store the Hono internal TLS certificate"
}

variable "legacy_load_balancer_setup_enabled" {
  type        = bool
  description = "Whether or not the legacy load balancer setup with Kubernetes Ingress and Cloud Endpoints should be enabled."
}
