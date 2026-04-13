locals {
  network_name    = "${var.instance_name}-network"
  subnetwork_name = "${var.instance_name}-subnet"
  ip_name         = "${var.instance_name}-ip"
  vm_tags         = ["collab-jupyter", var.instance_name]
}

resource "google_compute_network" "collab_jupyter" {
  name                    = local.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "collab_jupyter" {
  name          = local.subnetwork_name
  ip_cidr_range = "10.10.0.0/24"
  region        = var.gcp_region
  network       = google_compute_network.collab_jupyter.id
}

resource "google_compute_firewall" "allow_jupyter" {
  name    = "${var.instance_name}-allow-jupyter"
  network = google_compute_network.collab_jupyter.name

  allow {
    protocol = "tcp"
    ports    = [tostring(var.jupyter_port), "22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = local.vm_tags
}

resource "google_compute_address" "collab_jupyter" {
  name   = local.ip_name
  region = var.gcp_region
}

resource "google_compute_instance" "collab_jupyter" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.gcp_zone
  tags         = local.vm_tags

  allow_stopping_for_update = true

  scheduling {
    provisioning_model  = var.spot_instance ? "SPOT" : "STANDARD"
    preemptible         = var.spot_instance
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = var.disk_size_gb
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.collab_jupyter.id

    access_config {
      nat_ip = google_compute_address.collab_jupyter.address
    }
  }

  metadata_startup_script = templatefile("${path.module}/startup.sh.tftpl", {
    jupyter_port  = var.jupyter_port
    jupyter_token = var.jupyter_token
    notebook_dir  = var.notebook_dir
  })

  service_account {
    scopes = ["cloud-platform"]
  }

  labels = {
    app = "collab-jupyter"
  }
}
