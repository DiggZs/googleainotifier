resource "google_secret_manager_secret" "anthropic_api_key" {
  secret_id = "anthropic-api-key"
  project   = var.project_id

  replication {
    auto {}
  }

  depends_on = [google_project_service.apis]
}

# The secret value is managed outside Terraform to avoid storing it in state.
# After first apply, populate it:
#
#   echo -n "sk-ant-..." | \
#     gcloud secrets versions add anthropic-api-key \
#     --data-file=- --project=YOUR_PROJECT_ID
