resource "google_compute_network" "vpc" {
  name = "test-cluster"
  routing_mode = "REGIONAL"
  auto_create_subnetworks = false
  mtu = 1460
  delete_default_routes_on_create = false
}