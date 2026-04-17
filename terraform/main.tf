terraform {
  required_providers {
    nirvana = {
      source = "nirvana-labs/nirvana"
    }
  }
}

provider "nirvana" {}

# VPC for Node.js App
resource "nirvana_networking_vpc" "nodejs" {
  name        = var.vpc_name
  region      = var.region
  project_id  = var.project_id
  subnet_name = "${var.vpc_name}-subnet"
  tags        = var.tags
}

# Firewall rule - SSH access
resource "nirvana_networking_firewall_rule" "nodejs_ssh" {
  vpc_id              = nirvana_networking_vpc.nodejs.id
  name                = "nodejs-ssh"
  protocol            = "tcp"
  source_address      = "0.0.0.0/0"
  destination_address = nirvana_networking_vpc.nodejs.subnet.cidr
  destination_ports   = ["22"]
  tags                = var.tags
}

# Firewall rule - HTTP access
resource "nirvana_networking_firewall_rule" "nodejs_http" {
  vpc_id              = nirvana_networking_vpc.nodejs.id
  name                = "nodejs-http"
  protocol            = "tcp"
  source_address      = "0.0.0.0/0"
  destination_address = nirvana_networking_vpc.nodejs.subnet.cidr
  destination_ports   = ["80"]
  tags                = var.tags
}

# Firewall rule - HTTPS access
resource "nirvana_networking_firewall_rule" "nodejs_https" {
  vpc_id              = nirvana_networking_vpc.nodejs.id
  name                = "nodejs-https"
  protocol            = "tcp"
  source_address      = "0.0.0.0/0"
  destination_address = nirvana_networking_vpc.nodejs.subnet.cidr
  destination_ports   = ["443"]
  tags                = var.tags
}

# Node.js App VM
resource "nirvana_compute_vm" "nodejs" {
  name              = var.vm_name
  project_id        = var.project_id
  region            = var.region
  subnet_id         = nirvana_networking_vpc.nodejs.subnet.id
  public_ip_enabled = true
  os_image_name     = var.os_image
  instance_type     = var.instance_type

  boot_volume = {
    size = var.boot_volume_size
    type = "abs"
    tags = var.tags
  }

  ssh_key = {
    public_key = var.ssh_public_key
  }

  tags = var.tags
}
