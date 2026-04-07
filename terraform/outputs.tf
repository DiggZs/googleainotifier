output "cloud_run_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_v2_service.bot.uri
}

output "registry_url" {
  description = "Artifact Registry base URL for pushing images"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app.repository_id}"
}

output "wif_provider" {
  description = "Set as GCP_WIF_PROVIDER GitHub secret"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "deployer_service_account" {
  description = "Set as GCP_SERVICE_ACCOUNT GitHub secret"
  value       = google_service_account.deployer.email
}
