output "public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.vm-public-ip.ip_address
}