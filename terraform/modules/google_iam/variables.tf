variable "project_id" {
  type = string
}

variable "service_account_roles_gke_sa" {
  type        = list(string)
  description = "Additional roles to be added to the service account."
}

variable "legacy_load_balancer_setup_enabled" {
  type        = bool
  description = "Whether the legacy load balancer setup with Kubernetes Ingress, Cloud Endpoints and Cert Manager should be enabled."
}
