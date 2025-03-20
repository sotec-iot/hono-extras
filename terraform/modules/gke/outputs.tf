output "gke_cluster_name" {
  value       = var.gke_autopilot_enabled ? google_container_cluster.hono_autopilot_cluster[0].name : google_container_cluster.hono_cluster[0].name
  description = "Name of the GKE Cluster"
}
