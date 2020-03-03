output "ptfe-fqdn" {
  description = "The full URL to the pTFE instance."
  value       = "https://${azurerm_public_ip.main.fqdn}"
}

output "ptfe-vm-username" {
  description = "The admin username for the VM. Needed to SSH into the instance."
  value       = var.admin_username
}

output "ptfe-console-password" {
  description = "The password for the replicated console. Dynamically generated."
  value       = random_password.password.result
}