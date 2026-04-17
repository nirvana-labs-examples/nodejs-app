variable "project_id" {
  description = "Nirvana Labs project ID"
  type        = string
}

variable "region" {
  description = "Region to deploy resources"
  type        = string
  default     = "us-sva-2"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "nodejs-vpc"
}

variable "vm_name" {
  description = "Name of the Node.js VM"
  type        = string
  default     = "nodejs-app"
}

variable "instance_type" {
  description = "Instance type (e.g., n1-standard-2, n1-standard-4)"
  type        = string
  default     = "n1-standard-2"
}

variable "boot_volume_size" {
  description = "Boot volume size in GB"
  type        = number
  default     = 64
}

variable "os_image" {
  description = "Operating system image"
  type        = string
  default     = "ubuntu-noble-2025-10-01"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = list(string)
  default     = ["nodejs", "terraform"]
}
