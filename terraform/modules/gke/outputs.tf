output "gke_cluster_name" {
  value       = var.gke_autopilot_enabled ? google_container_cluster.hono_autopilot_cluster[0].name : google_container_cluster.hono_cluster[0].name
  description = "Name of the GKE Cluster"
}

output "gke_cluster_name_endpoint" {
  value       = var.gke_autopilot_enabled ? google_container_cluster.hono_autopilot_cluster[0].endpoint : google_container_cluster.hono_cluster[0].endpoint
  description = "Endpoint of the GKE Cluster"
}

output "gke_cluster_ca_certificate" {
  value       = var.gke_autopilot_enabled ? google_container_cluster.hono_autopilot_cluster[0].master_auth : google_container_cluster.hono_cluster[0].master_auth
  description = "CA-Certificate for the Cluster"
  sensitive   = true
}
