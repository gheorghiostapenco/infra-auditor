# terraform-examples/bad-infra/main.tf
# (Now "fixed"!)

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

# 1. COST FIX (from n2-standard-16 to e2-micro)
resource "google_compute_instance" "expensive_vm" {
  name         = "cheap-vm-demo" # Renamed
  machine_type = "e2-micro"      # <-- THIS IS CHEAP!
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

# 2. SECURITY FIX (from 0.0.0.0/0 to a specific IP)
resource "google_compute_firewall" "ssh_to_world" {
  name    = "allow-ssh-from-home" # Renamed
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  # We now source only from a specific "safe" IP.
  # Checkov will no longer complain.
  source_ranges = ["1.2.3.4/32"] # <-- THIS IS SAFE! 
  target_tags   = ["devops-auditor-demo"]
}