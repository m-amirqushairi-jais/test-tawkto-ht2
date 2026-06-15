resource "google_compute_instance" "mongodb" {
  count        = var.replica_count
  name         = "${var.name}-${count.index + 1}"
  machine_type = "n1-standard-1"
  zone         = var.zone # task 2: fix 1 - declare in variables.tf but never used, remove hardcoded zone and use variable instead

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = var.disk_size_gb # task 2: fix 2 - typo should match variable name in variables.tf
    }
  }

  network_interface {
    network = "default"
    // access_config {} # task 2: fix 3 - should remove the access_config block to avoid assigning a public IP
  }

  labels = merge({
    database = "mongodb"
  }, var.labels)
}
