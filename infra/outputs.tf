output "vm_public_ip" {
  value       = azurerm_public_ip.ai_app.ip_address
  description = "Public IP address of the VM"
  sensitive   = true  # Mark as sensitive
}

output "ssh_command" {
  value       = "ssh -i ~/.ssh/id_rsa ${var.vm_username}@${azurerm_public_ip.ai_app.ip_address}"
  description = "SSH access command"
  sensitive   = true  # This was missing
}

output "application_url" {
  value       = "http://${azurerm_public_ip.ai_app.ip_address}:5000"
  description = "URL to access the application"
  # Not marked sensitive as this is meant to be public
}