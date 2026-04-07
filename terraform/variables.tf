variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for all resources"
  type        = string
  default     = "us-central1"
}

variable "image_url" {
  description = "Full Docker image URL including digest, e.g. REGION-docker.pkg.dev/PROJECT/REPO/NAME@sha256:..."
  type        = string
}

variable "chat_space_name" {
  description = "Google Chat space name, e.g. spaces/ABC123"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository in owner/repo format, used for Workload Identity Federation attribute condition"
  type        = string
}

variable "scheduler_cron" {
  description = "Cron expression for Cloud Scheduler (default: 9am Mon-Fri)"
  type        = string
  default     = "0 9 * * 1-5"
}

variable "scheduler_timezone" {
  description = "IANA timezone for Cloud Scheduler"
  type        = string
  default     = "America/New_York"
}
