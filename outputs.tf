output "cloud_run_url" {
  value = google_cloud_run_service.django.status[0].url
}
