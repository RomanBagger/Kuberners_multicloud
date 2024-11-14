resource "google_compute_address" "address" {
  count  = 2
  name   = "nat-manual-ip-${count.index}"
  region = google_compute_subnetwork.subnet.region

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_router_nat_address" "nat_address" {
  nat_ips = [google_compute_address.address[0].self_link, google_compute_address.address[1].self_link]
  router = google_compute_router.router.name
  router_nat = google_compute_router_nat.router_nat.name
  region = google_compute_router_nat.router_nat.region
}

resource "google_compute_router_nat" "router_nat" {
  name   = "my-router-nat"
  router = google_compute_router.router.name
  region = google_compute_router.router.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.address[0].self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
