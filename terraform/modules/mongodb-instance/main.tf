resource "google_compute_instance" "mongodb" {
  count        = var.replica_count
  name         = "${var.name}-${count.index + 1}"
  machine_type = "n1-standard-1"
  zone         = var.zones[count.index % length(var.zones)] # improvement 5 - distributes instances round-robin across zones; single zone failure won't take down all replicas

  tags = ["mongodb-replica"] # improvement 6 - network tag matched by the firewall rule; only tagged instances can reach port 27017

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
