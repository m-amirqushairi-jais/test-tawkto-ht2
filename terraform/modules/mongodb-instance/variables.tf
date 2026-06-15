variable "name" {
  type        = string
  description = "Base name for the MongoDB instances."
}

variable "replica_count" {
  type    = number # task 2: fix 4 - need to define the type for the variable to prevent errors if someone passes a non-number value
  description = "Number of MongoDB instances to create." # task 2: fix 5 - add description for the variable to improve code readability and maintainability
  default = 2
}

variable "zone" { # task 2: fix 1 - declare but never used
  type    = string
  description = "Zone where the MongoDB instances will be created." # task 2: fix 2 - add description for the variable to improve code readability and maintainability
  default = "us-central1-a"
}

variable "disk_size_gb" {
  type    = number
  description = "Size of the disk for each MongoDB instance." # task 2: fix 6 - add description for the variable to improve code readability and maintainability
  default = 100
}

variable "labels" {
  type    = map(string)
  description = "Labels to apply to the MongoDB instances." # task 2: fix 7 - add description for the variable to improve code readability and maintainability
  default = {}
}
