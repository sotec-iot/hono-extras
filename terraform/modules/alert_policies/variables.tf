variable "project_id" {
  type        = string
  description = "The project ID to deploy to"
}

variable "alerts_chat_space_id" {
  type        = string
  description = "The Chat space ID is the string following “chat/space/” in the chat URL. It can only be seen in the web view of the Chat app. In order to add Google Chat as a notification channel, you must first add the Google Cloud Monitoring App to the chat space. You can add the app directly to a space by typing @Google Cloud Monitoring."
}

variable "hono_namespace" {
  type        = string
  description = "namespace of the deployment"
}

variable "cert_manager_namespace" {
  type        = string
  description = "Namespace of the cert manager deployment."
}