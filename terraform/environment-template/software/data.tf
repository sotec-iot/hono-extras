data "terraform_remote_state" "infrastructure" {
  backend = "gcs"

  config = {
    bucket = local.bucket_name
    prefix = "terraform/infrastructure"
  }
}

data "google_client_config" "default" {}

data "google_container_cluster" "default" {
  name     = data.terraform_remote_state.infrastructure.outputs.cluster_name
  location = data.terraform_remote_state.infrastructure.outputs.region
  project  = data.terraform_remote_state.infrastructure.outputs.project_id
}
data "terraform_remote_state" "software" {
  backend = "gcs"

  config = {
    bucket = local.bucket_name
    prefix = "terraform/software"
  }
}
