terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4"
    }
    mongodbatlas = {
      source = "mongodb/mongodbatlas"
      version = "~> 1"
    }
  }
}

provider "google" {
  project = local.project_id
  region  = local.region
  zone    = local.zone
}

provider "google-beta" {
  project = local.project_id
  region  = local.region
  zone    = local.zone
}

provider "mongodbatlas" {
  private_key = local.atlas_mongodb_provider_private_key
  public_key = local.atlas_mongodb_provider_public_key

}
