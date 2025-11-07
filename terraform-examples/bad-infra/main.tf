# terraform-examples/prod-infra/main.tf

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# ----------------------
# VARIABLES
# ----------------------
variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP region"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "GCP zone"
  default     = "us-central1-a"
}

variable "ssh_allowed_ip" {
  type        = string
  description = "IP address allowed for SSH"
  default     = "1.2.3.4/32"
}

variable "vm_name" {
  type        = string
  description = "Name of the VM"
  default     = "cheap-vm-prod"
}

variable "machine_type" {
  type        = string
  description = "Type of VM machine"
  default     = "e2-micro"
}

variable "disk_size_gb" {
  type        = number
  description = "Boot disk size in GB"
  default     = 10
}

variable "disk_type" {
  type        = string
  description = "Boot disk type"
  default     = "pd-ssd"
}

variable "image_family" {
  type        = string
  description = "OS image family"
  default     = "debian-11"
}

variable "image_project" {
  type        = string
  description = "OS image project"
  default     = "debian-cloud"
}

# New variable for Customer Supplied Encryption Key
variable "csek_raw_key" {
  type        = string
  description = "Base64-encoded 256-bit Customer Supplied Encryption Key (CSEK)"
}

# ----------------------
# NETWORKING
# ----------------------
resource "google_compute_network" "vpc" {
  name                    = "prod-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "prod-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# ----------------------
# FIREWALL
# ----------------------
resource "google_compute_firewall" "ssh_firewall" {
  name    = "allow-ssh-from-home"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [var.ssh_allowed_ip]
  target_tags   = ["devops-auditor-prod"]
}

# ----------------------
# VIRTUAL MACHINE
# ----------------------
resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "${var.image_project}/${var.image_family}"
      size  = var.disk_size_gb
      type  = var.disk_type
    }

    # ----------------------
    # CSEK: Customer Supplied Encryption Key
    # ----------------------
    disk_encryption_key {
      raw_key = var.csek_raw_key
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {}
  }

  tags = ["devops-auditor-prod"]
}
