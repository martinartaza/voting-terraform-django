variable "project_id" {
  description = "ID del proyecto de Google Cloud"
  type        = string
}

variable "region" {
  description = "Región de Google Cloud donde se desplegarán los recursos"
  type        = string
  default     = "us-central1"
}

variable "db_user" {
  description = "Usuario de la base de datos"
  type        = string
}

variable "db_password" {
  description = "Contraseña de la base de datos"
  type        = string
  sensitive   = true
}

variable "django_secret_key" {
  description = "Clave secreta de Django"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "Propietario del repositorio de GitHub"
  type        = string
}

variable "github_repo" {
  description = "Nombre del repositorio de GitHub"
  type        = string
}

variable "cloudbuild_trigger_name" {
  description = "Nombre del trigger de Cloud Build"
  type        = string
  default     = "terraform-django-clean-project-trigger-push"
}

variable "DJANGO_SUPERUSER_USERNAME" {
  description = "Usuario administrador de Django"
  type        = string
}

variable "DJANGO_SUPERUSER_EMAIL" {
  description = "Email del administrador de Django"
  type        = string
}

variable "DJANGO_SUPERUSER_PASSWORD" {
  description = "Contraseña del administrador de Django"
  type        = string
  sensitive   = true
}