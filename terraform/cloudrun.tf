resource "google_cloud_run_v2_service" "bot" {
  name     = "google-ai-notifier"
  location = var.region
  project  = var.project_id

  # Only Cloud Scheduler (internal) can reach this — no public ingress
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    service_account = google_service_account.bot.email

    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }

    containers {
      image = var.image_url

      env {
        name  = "CHAT_SPACE_NAME"
        value = var.chat_space_name
      }

      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
        startup_cpu_boost = true
      }

      liveness_probe {
        http_get {
          path = "/health"
        }
      }
    }
  }

  depends_on = [
    google_project_service.apis,
    google_project_iam_member.bot_vertex_user,
  ]
}
