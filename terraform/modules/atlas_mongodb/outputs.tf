output "mongodb_pw" {
  value       = random_password.password.result
  description = "Output of the MongoDB user password."
  sensitive   = true
}

output "mongodb_user" {
  value       = mongodbatlas_database_user.mongodb_user.username
  description = "Output of the MongoDB user name."
}

output "mongodb_cluster_connection_string" {
  value       = mongodbatlas_advanced_cluster.mongodb_cluster.connection_strings.0.private_srv
  description = "Connection string for the MongoDB cluster."
}
