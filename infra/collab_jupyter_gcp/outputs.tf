output "jupyter_ip" {
  description = "Static public IP address of the JupyterLab VM."
  value       = google_compute_address.collab_jupyter.address
}

output "instance_name" {
  description = "Name of the VM instance."
  value       = google_compute_instance.collab_jupyter.name
}
