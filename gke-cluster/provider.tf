terraform {
  backend "gcs" {
    bucket = "bucket-for-tfstate-and-azure-pipeline"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.9.0"
    }
  }
}

provider "google" {
  project     = "velvety-gearbox-439710-c9"
  region      = "us-central1"
}
