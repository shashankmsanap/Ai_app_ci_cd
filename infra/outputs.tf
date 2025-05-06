output "vm_public_ip" {
  value       = azurerm_public_ip.ai_app.ip_address
  description = "Public IP of the AI app VM"
}

output "ssh_command" {
  value       = "ssh ${var.vm_username}@${azurerm_public_ip.ai_app.ip_address}"
  description = "SSH access command"
}