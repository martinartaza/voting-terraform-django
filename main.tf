provider "google" {
  project = var.project_id
  region  = var.region
}

# Habilitar APIs necesarias
resource "google_project_service" "required" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudbuild.googleapis.com",
    "servicenetworking.googleapis.com"
  ])
  project = var.project_id
  service = each.key
}

# Red de VPC necesaria para Cloud SQL
resource "google_compute_network" "default" {
  name                    = "default-vpc"
  auto_create_subnetworks = true
}

# IP privada para Cloud SQL
resource "google_compute_global_address" "private_ip" {
  name          = "sql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.default.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.default.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip.name]
}

# Instancia de Cloud SQL
resource "google_sql_database_instance" "default" {
  name             = "django-instance"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.default.id
      authorized_networks {
        name  = "all"
        value = "0.0.0.0/0"
      }
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# Base de datos dentro de la instancia
resource "google_sql_database" "app_db" {
  name     = "django"
  instance = google_sql_database_instance.default.name
}

# Usuario para la DB
resource "google_sql_user" "app_user" {
  name     = var.db_user
  password = var.db_password
  instance = google_sql_database_instance.default.name
}

# Secretos para Django
resource "google_secret_manager_secret" "django_secret_key" {
  secret_id = "django-secret-key"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "django_secret_key_version" {
  secret      = google_secret_manager_secret.django_secret_key.id
  secret_data = var.django_secret_key
}

# Repositorio de imágenes
resource "google_artifact_registry_repository" "django_repo" {
  location      = var.region
  repository_id = "django-repo"
  format        = "DOCKER"
}

# Cloud Build para construir imagen desde GitHub
# Nota: El trigger se crea manualmente desde la consola web
# para evitar conflictos con la configuración de GitHub

# Cloud Run (se puede actualizar luego de primer build)
resource "google_cloud_run_service" "django" {
  name     = "django-service"
  location = var.region

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "20"
        "run.googleapis.com/startup-cpu-boost" = "true"
      }
    }
    spec {
      containers {
                image = "us-central1-docker.pkg.dev/${var.project_id}/django-repo/django:latest"
        
        ports {
          container_port = 8080
        }
        
        env {
          name  = "DJANGO_SECRET_KEY"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.django_secret_key.secret_id
              key  = "latest"
            }
          }
        }
        env {
          name  = "DB_NAME"
          value = "django"
        }
        env {
          name  = "DB_USER"
          value = var.db_user
        }
        env {
          name  = "DB_PASSWORD"
          value = var.db_password
        }
        env {
          name  = "DB_HOST"
          value = google_sql_database_instance.default.public_ip_address
        }
        env {
          name  = "DB_PORT"
          value = "5432"
        }
        env {
          name  = "DJANGO_SETTINGS_MODULE"
          value = "config.settings"
        }
        env {
          name  = "DATABASE_URL"
          value = "postgresql://${var.db_user}:${var.db_password}@${google_sql_database_instance.default.public_ip_address}:5432/${google_sql_database.app_db.name}"
        }
        env {
          name  = "CUSTOM_DOMAIN"
          value = var.custom_domain
        }
        env {
          name  = "DEBUG"
          value = "False"
        }
        env {
            name  = "DJANGO_SUPERUSER_USERNAME"
            value = var.DJANGO_SUPERUSER_USERNAME
            }
        env {
            name  = "DJANGO_SUPERUSER_EMAIL"
            value = var.DJANGO_SUPERUSER_EMAIL
            }
        env {
            name  = "DJANGO_SUPERUSER_PASSWORD"
            value = var.DJANGO_SUPERUSER_PASSWORD
        }

      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_artifact_registry_repository.django_repo,
    google_secret_manager_secret_iam_member.secret_accessor
  ]
}

# Permisos para que Cloud Run pueda acceder a los secretos
resource "google_secret_manager_secret_iam_member" "secret_accessor" {
  secret_id = google_secret_manager_secret.django_secret_key.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:412606009447-compute@developer.gserviceaccount.com"
}

# Permisos para que cualquiera pueda invocar Cloud Run
resource "google_cloud_run_service_iam_member" "all_users" {
  service = google_cloud_run_service.django.name
  location = google_cloud_run_service.django.location
  role    = "roles/run.invoker"
  member  = "allUsers"
}
