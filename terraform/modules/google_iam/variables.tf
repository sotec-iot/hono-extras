variable "project_id" {
  type = string
}

variable "service_name_communication" {
  type        = string
  description = "Name of the Cloud Endpoint service for device communication."
}

variable "service_account_roles_gke_sa" {
  type        = list(string)
  description = "Additional roles to be added to the service account."
}

variable "enable_cert_manager" {
  type        = bool
  description = "Enables the service account needed for the use of cert manager."
}

variable "cert_manager_sa_account_id" {
  type        = string
  description = "ID under which the cert-manager service account is going to be created."
}

variable "cert_manager_issuer_project_id" {
  type        = string
  description = "Project ID in which the Cloud DNS zone to manage the DNS entries is located. Defaults to use the same project ID as the Hono instance."
}
