output "public_ip" {
  description = "Public IP address of the VM"
  value       = module.linux_vm.public_ip
}