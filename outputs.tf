output "cloud_run_url" {
  value = google_cloud_run_service.django.status[0].url
}

output "database_connection_info" {
  description = "Database connection information"
  value = {
    host     = google_sql_database_instance.default.public_ip_address
    port     = "5432"
    database = google_sql_database.app_db.name
    username = google_sql_user.app_user.name
  }
  sensitive = false
}

output "database_url" {
  description = "Complete database URL for external connections"
  value = "postgresql://${var.db_user}:${var.db_password}@${google_sql_database_instance.default.public_ip_address}:5432/${google_sql_database.app_db.name}"
  sensitive = true
}

output "dns_configuration" {
  description = "DNS configuration information for Route 53"
  value = {
    custom_domain = var.custom_domain
    service_url   = google_cloud_run_service.django.status[0].url
    cname_target  = replace(google_cloud_run_service.django.status[0].url, "https://", "")
    service_name  = google_cloud_run_service.django.name
  }
}
