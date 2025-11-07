# main.tf (The "bad" GCP code with English comments)

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  # Authentication is handled by the GCP_SA_KEY secret.
  # The GCP_PROJECT_ID secret will be used in our
  # GitHub Action to set the GOOGLE_PROJECT env var.
  region = "us-central1"
  zone   = "us-central1-a"
}

# 1. COST PROBLEM (for Infracost)
# We are creating a very large, expensive compute instance.
# n2-standard-16 (16 vCPUs, 64GB RAM) costs hundreds
# of dollars per month.
# Infracost should flag this high cost in the PR.
resource "google_compute_instance" "expensive_vm" {
  name         = "expensive-vm-demo"
  machine_type = "n2-standard-16" # <-- THIS IS EXPENSIVE!
  zone         = "us-central1-a"

  # A boot disk is required
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # A network interface is required
  network_interface {
    network = "default"
  }

  tags = ["devops-auditor-demo"]
}

# 2. SECURITY PROBLEM (for Checkov)
# We are creating a firewall rule that opens SSH (port 22)
# to the entire internet (0.0.0.0/0).
# This is a critical vulnerability.
# Checkov will fail the build because of this.
resource "google_compute_firewall" "ssh_to_world" {
  name    = "allow-ssh-to-world"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # This is the security vulnerability.
  source_ranges = ["0.0.0.0/0"] # <-- THIS IS VERY BAD!

  # We apply this rule to all instances with the tag
  target_tags = ["devops-auditor-demo"]
}