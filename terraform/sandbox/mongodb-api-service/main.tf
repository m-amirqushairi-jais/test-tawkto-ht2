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
  replica_count = 3           # improvement 7 - odd count is required for replica set majority election; 2 nodes cannot elect a primary on failure
  zones         = ["us-central1-a", "us-central1-b", "us-central1-c"] # improvement 5 - three zones so each replica lands in a different zone
  disk_size_gb  = 100

  labels = {
    environment = "sandbox"
    replica_set = "mongodb-api-service"
  }
}
