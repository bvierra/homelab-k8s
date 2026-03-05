output "ip_address" {
  value = proxmox_virtual_environment_vm.vm.ipv4_addresses
}
