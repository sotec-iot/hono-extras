variable "project_id" {
  type        = string
  description = "The project ID to deploy to"
}

variable "gke_notification_enabled" {
  type        = bool
  description = "Enables notification emails for some Google Kubernetes Engine events (UPGRADE_AVAILABLE_EVENT, UPGRADE_EVENT and SECURITY_BULLETIN_EVENT)."
}

variable "gke_notification_pubsub_topic" {
  type        = string
  description = "The topic to which the google cluster notifications are published to."
}
