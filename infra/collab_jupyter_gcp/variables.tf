variable "gcp_project_id" {
  description = "GCP project ID used for the deployment."
  type        = string
}

variable "gcp_region" {
  description = "GCP region for network resources."
  type        = string
}

variable "gcp_zone" {
  description = "GCP zone for the VM."
  type        = string
}

variable "instance_name" {
  description = "Name of the Jupyter VM."
  type        = string
  default     = "collab-jupyter"
}

variable "machine_type" {
  description = "GCE machine type."
  type        = string
  default     = "e2-standard-2"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB."
  type        = number
  default     = 30
}

variable "jupyter_port" {
  description = "Port exposed by JupyterLab."
  type        = number
  default     = 8888
}

variable "jupyter_token" {
  description = "Shared token used to access JupyterLab."
  type        = string
  sensitive   = true
}

variable "notebook_dir" {
  description = "Directory served by JupyterLab."
  type        = string
  default     = "/srv/collab-notebooks"
}

variable "spot_instance" {
  description = "Whether to run the VM as a Spot instance."
  type        = bool
  default     = true
}
