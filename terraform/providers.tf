terraform {
  required_version = ">= 1.7"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Configured via CLI flags in CI/CD and during bootstrap:
  #   terraform init \
  #     -backend-config="bucket=YOUR_TF_STATE_BUCKET" \
  #     -backend-config="prefix=google-ai-notifier"
  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
}
