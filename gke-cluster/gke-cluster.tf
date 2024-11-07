resource "google_service_account" "kubernetes" {
  account_id   = "kubernetes"
  display_name = "kubernetes"
}

resource "google_container_cluster" "primary" {
  name     = "my-gke-cluster"
  location = "us-central1-a"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
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

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.kubernetes.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}
