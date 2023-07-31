output "sql_db_pw" {
  value       = google_sql_user.hono-sql-user.password
  description = "Output of the SQL user password."
  sensitive   = true
}

output "sql_user" {
  value       = google_sql_user.hono-sql-user.name
  description = "Output of the SQL user name."
}

output "sql_ip" {
  value       = google_sql_database_instance.hono_sql.private_ip_address
  description = "URL of the postgres database."
}

output "sql_hono_database" {
  value       = google_sql_database.hono_sql_db.name
  description = "Name of the hono postgres database."
}

output "sql_grafana_database" {
  value       = google_sql_database.grafana_sql_db.name
  description = "Name of the grafana postgres database."
}
