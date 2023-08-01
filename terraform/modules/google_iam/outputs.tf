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

output "cloud_endpoints_key_file" {
  value       = google_service_account_key.endpoints_sa_key.private_key
  description = "Service Account Key File for Cloud Endpoints Service Account"
  sensitive   = true
}

output "cert_manager_sa_account_id" {
  value       = google_service_account.cert_manager_sa[*].account_id
  description = "Account id of the cert-manager Service Account"
}

output "cert_manager_sa_key_file" {
  value       = google_service_account_key.cert_manager_sa_key[*].private_key
  description = "Service Account Key File for cert-manager Service Account"
  sensitive   = true
}

output "cert_manager_issuer_project_id" {
  value        = google_service_account.cert_manager_sa[*].project
  description = "Project ID in which the Cloud DNS zone to manage the DNS entries is located."
}
