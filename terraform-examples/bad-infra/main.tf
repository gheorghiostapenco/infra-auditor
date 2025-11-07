# terraform-examples/bad-infra/main.tf

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  region = "us-central1"
  zone   = "us-central1-a"
}

# 1. COST PROBLEM (for Infracost)
resource "google_compute_instance" "expensive_vm" {
  name         = "expensive-vm-demo"
  machine_type = "n2-standard-16" # <-- THIS IS EXPENSIVE!
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }

  tags = ["devops-auditor-demo"]
}

# 2. SECURITY PROBLEM (for Checkov)
resource "google_compute_firewall" "ssh_to_world" {
  name    = "allow-ssh-to-world"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # <-- THIS IS VERY BAD!
  target_tags   = ["devops-auditor-demo"]
}