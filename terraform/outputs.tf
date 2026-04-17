output "vm_id" {
  description = "Node.js VM ID"
  value       = nirvana_compute_vm.nodejs.id
}

output "vm_public_ip" {
  description = "Node.js VM public IP"
  value       = nirvana_compute_vm.nodejs.public_ip
}

output "vm_private_ip" {
  description = "Node.js VM private IP"
  value       = nirvana_compute_vm.nodejs.private_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = nirvana_networking_vpc.nodejs.id
}

output "app_url" {
  description = "Application URL"
  value       = "http://${nirvana_compute_vm.nodejs.public_ip}"
}
