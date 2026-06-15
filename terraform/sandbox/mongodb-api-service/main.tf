terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 7.0" # task 2: fix 8 - specify the version of the Google provider to ensure compatibility and prevent issues with future updates
    }
  }
}

provider "google" {
  project = "synthetic-sandbox"
  region  = "us-central1"
}

module "mongodb" {
  source = "../../modules/mongodb-instance"

  name          = "mongodb-api-service"
  replica_count = 2
  zone          = "us-central1-a"
  disk_size_gb  = 100

  labels = {
    environment = "sandbox"
    replica_set = "mongodb-api-service"
  }
}
