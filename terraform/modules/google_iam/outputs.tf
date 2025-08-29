output "gke_service_account_email" {
  value       = google_service_account.gke_service_account.email
  description = "Email of the GKE Service Account"
}

output "gke_service_account_name" {
  value       = google_service_account.gke_service_account.name
  description = "Name of the GKE Service Account"
}

output "cloud_endpoints_sa_name" {
  value       = google_service_account.cloud_endpoints_sa.name
  description = "Name of the Cloud Endpoints Service Account"
}
