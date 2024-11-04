terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.9.0"
    }
  }
}

provider "google" {
  project     = "my-project-test"
  region      = "us-central1"
}