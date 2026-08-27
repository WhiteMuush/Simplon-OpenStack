output "public_ip" {
  description = "Public address, used by the Ansible inventory"
  value       = azurerm_public_ip.lab.ip_address
}

output "private_ip" {
  description = "Private address, this is what DevStack HOST_IP must hold"
  value       = azurerm_network_interface.lab.private_ip_address
}

output "admin_username" {
  value = var.admin_username
}
