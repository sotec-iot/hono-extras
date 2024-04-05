locals {
  project_id          = "<project_id>"                                           # Insert your project id
  region              = "europe-west1"                                           # Insert the region for your cluster
  zone                = "europe-west1-b"                                         # Insert the zone for your cluster and SQL database
  node_locations      = ["europe-west1-c", "europe-west1-b", "europe-west1-d"]   # Insert the node locations for your cluster
  enable_cert_manager = false                                                    # Toggle to enable the creation of service account needed for the cert-manager

  # If database_type is not set to "mongodb" the following two properties can be ignored
  atlas_mongodb_provider_private_key = "" # Private key of an Atlas organization api key
  atlas_mongodb_provider_public_key = "" # Public key of an Atlas organization api key
}
