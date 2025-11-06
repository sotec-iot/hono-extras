variable "hono_namespace" {
  type        = string
  description = "Namespace of the hono deployment."
}

variable "cert_manager_namespace" {
  type        = string
  description = "Namespace of the cert manager deployment."
}

variable "enable_cert_manager" {
  type        = bool
  description = "Enables the creation of the cert-manager namespace. Only relevant if legacy_load_balancer_setup_enabled is set to true"
}

variable "legacy_load_balancer_setup_enabled" {
  type        = bool
  description = "Whether the legacy load balancer setup with Kubernetes Ingress, Cloud Endpoints and Cert Manager should be enabled."
}