variable "project_id" {
  type        = string
  description = "Project ID in which the cluster is present"
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
  description = "When to renew the certificate based on its remaining validity period (e.g. 360h for 15 days before expiration)."
}

variable "wildcard_domain" {
  type        = string
  description = "The wildcard domain the secret will be maintained for (e.g. *.root-domain.com)."
}

variable "hono_trust_store_config_map_name" {
  type        = string
  description = "Name of the kubernetes trust store config map for the hono deployments managed by trust-manager."
}
