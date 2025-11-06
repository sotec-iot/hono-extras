data "google_project" "project" {
  project_id = var.project_id
}

data "google_compute_zones" "available_zones" {}