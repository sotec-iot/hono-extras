terraform {
  backend "gcs" {
    bucket = "<bucket_name>"    # Insert the name of the storage bucket
    prefix = "terraform/infrastructure"
  }
}
