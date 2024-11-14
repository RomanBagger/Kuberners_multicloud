resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_container_cluster" "primary" {
  deletion_protection = false
  name     = "my-gke-cluster"
  location = "us-central1-a"

  remove_default_node_pool = true
  initial_node_count       = 2
  network = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "us-central1-a"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
