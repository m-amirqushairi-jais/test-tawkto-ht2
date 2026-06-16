# improvement 6 - internal-only firewall rule; port 27017 is open only between instances tagged mongodb-replica, not exposed to the internet
resource "google_compute_firewall" "mongodb_internal" {
  name    = "${var.name}-internal"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  # Allow MongoDB traffic only between instances tagged as replica set members.
  source_tags = ["mongodb-replica"]
  target_tags = ["mongodb-replica"]
}
