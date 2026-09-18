data "google_project" "project" {
  project_id = var.project_id
}

data "google_compute_zones" "available_zones" {}

data "google_secret_manager_secret_version" "oauth_client_id" {
  project = var.project_id
  secret  = var.oauth_client_id_key
}

data "google_secret_manager_secret_version" "oauth_client_secret" {
  project = var.project_id
  secret  = var.oauth_client_secret_key
}