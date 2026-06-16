terraform {
  # improvement 8 - replaced S3 (AWS) backend with GCS; S3 region us-east-1 mismatches GCP provider and has no state locking for GCP projects
  backend "gcs" {
    bucket = "synthetic-terraform-state-sandbox"
    prefix = "mongodb-api-service"
  }
}
