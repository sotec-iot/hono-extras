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
  description = "Enables the creation of the cert-manager namespace."
}