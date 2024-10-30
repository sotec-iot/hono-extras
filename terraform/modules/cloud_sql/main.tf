# Creating the Postgres SQL database instance
resource "google_sql_database_instance" "hono_sql" {
  project          = var.project_id
  region           = var.region
  name             = var.sql_instance_name
  database_version = var.sql_instance_version

  settings {
    tier                        = var.sql_instance_machine_type
    disk_size                   = var.storage_size_gb
    disk_type                   = var.sql_instance_disk_type
    activation_policy           = var.sql_instance_activation_policy
    deletion_protection_enabled = var.sql_instance_deletion_protection_enabled

    dynamic "maintenance_window" {
      for_each = var.sql_instance_maintenance_window != null ? [1] : []
      content {
        day          = var.sql_instance_maintenance_window.day
        hour         = var.sql_instance_maintenance_window.hour
        update_track = var.sql_instance_maintenance_window.update_track
      }
    }

    ip_configuration {
      ipv4_enabled    = var.sql_public_ip_enable
      private_network = var.network_id
    }
    backup_configuration {
      enabled    = var.sql_instance_backup_enabled
      location   = var.sql_instance_backup_location != null ? var.sql_instance_backup_location : var.region
      start_time = var.sql_instance_backup_start_time
      backup_retention_settings {
        retained_backups = var.sql_instance_backup_count
      }
    }
  }
  depends_on = [var.service_networking]
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]}<>:?"
}

resource "google_sql_user" "hono-sql-user" {
  name     = var.sql_db_user_name
  instance = google_sql_database_instance.hono_sql.id
  password = random_password.password.result
  project  = var.project_id
}

resource "google_sql_database" "hono_sql_db" {
  name     = var.sql_hono_database_name
  instance = google_sql_database_instance.hono_sql.id
  project  = var.project_id
}

resource "google_sql_database" "grafana_sql_db" {
  name     = var.sql_grafana_database_name
  instance = google_sql_database_instance.hono_sql.id
  project  = var.project_id
}
