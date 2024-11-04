resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "ssh"
    ports = ["22"]
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1000-2000"]
  }

  source_ranges = [ "0.0.0.0/0" ]

  source_tags = ["web"]
}
