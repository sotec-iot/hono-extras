variable "project_id" {
  type        = string
  description = "The project ID to deploy to"
}

variable "region" {
  type        = string
  description = "The region to deploy to"
}

variable "ip_cidr_range" {
  type        = string
  description = "The range of internal addresses that are owned by this subnetwork. Provide this property when you create the subnetwork.Ranges must be unique and non-overlapping within a network. Only IPv4 is supported."
}

variable "secondary_ip_range_service" {
  type        = string
  description = "Secondary IP Range for Services"
}

variable "secondary_ip_range_pods" {
  type        = string
  description = "Secondary IP Range for Pods"
}

variable "enable_http_ip_creation" {
  type        = string
  description = "Used to enable the creation of a static ip for the http adapter"
}

variable "enable_mqtt_ip_creation" {
  type        = string
  description = "Used to enable the creation of a static ip for the mqtt adapter"
}

variable "ssl_policy_name" {
  type        = string
  description = "The name of the SSL policy"
}

variable "ssl_policy_profile" {
  type        = string
  description = "The profile of the SSL policy"
}

variable "ssl_policy_min_tls_version" {
  type        = string
  description = "The minimum TLS version the SSL policy should allow"
}
