resource "google_cloud_scheduler_job" "bot" {
  name      = "google-ai-notifier-job"
  project   = var.project_id
  region    = var.region
  schedule  = var.scheduler_cron
  time_zone = var.scheduler_timezone

  http_target {
    uri         = "${google_cloud_run_v2_service.bot.uri}/run-scheduled-task"
    http_method = "POST"

    oidc_token {
      service_account_email = google_service_account.scheduler.email
      audience              = google_cloud_run_v2_service.bot.uri
    }
  }

  depends_on = [
    google_project_service.apis,
    google_cloud_run_v2_service_iam_member.scheduler_invoker,
  ]
}
