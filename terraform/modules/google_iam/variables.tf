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