variable "name" {
  type        = string
  description = "Base name for the MongoDB instances."
}

variable "replica_count" {
  type        = number
  description = "Number of MongoDB replica set instances to create."
  default     = 2
}

variable "zones" {
  type        = list(string)
  description = "List of GCP zones to distribute MongoDB instances across for high availability."
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
  # improvement 5 - was a single zone string; changed to list so main.tf can distribute instances across zones using modulo
}

variable "disk_size_gb" {
  type        = number
  description = "Boot disk size in GB for each MongoDB instance."
  default     = 100
}

variable "labels" {
  type        = map(string)
  description = "Labels to apply to all MongoDB instances."
  default     = {}
}
