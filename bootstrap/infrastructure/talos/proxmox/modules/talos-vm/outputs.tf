output "vm_id" {
  description = "Proxmox VM ID of the node"
  value       = { for k, v in proxmox_virtual_environment_vm.talos_node : k => v.vm_id }
}

output "name" {
  description = "Name of the nodes"
  value       = { for k, v in var.nodes : v.vm_id => k }
}

output "vm_node_mapping" {
  description = "Map of talos VMs to Proxmox nodes"
  value       = { for k, v in proxmox_virtual_environment_vm.talos_node : k => v.node_name }
}

output "ip_addresses" {
  description = "IP addresses assigned to the node"
  value       = { for k, v in proxmox_virtual_environment_vm.talos_node : k => [for ip_list in v.ipv4_addresses : ip_list[0] if length(ip_list) > 0 && ip_list[0] != "127.0.0.1" && ip_list[0] != ""] }
}

output "ip_address" {
  description = "Primary IP address of the node"
  value       = { for k, v in proxmox_virtual_environment_vm.talos_node : k => try(
      v.ipv4_addresses[0][0],
      var.nodes[k].network_config["net0"].ip != null ? var.nodes[k].network_config["net0"].ip : "DHCP-assigned"
    ) }
#  value       = try(proxmox_virtual_environment_vm.talos_node.ipv4_addresses[0][0], var.ip_address != null ? var.ip_address : "DHCP-assigned")
}

output "cp_ip_addresses" {
  description = "IP addresses for control plane nodes"
  value       = { for k, v in proxmox_virtual_environment_vm.talos_node : k => [for ip_list in v.ipv4_addresses : ip_list[0] if length(ip_list) > 0 && ip_list[0] != "127.0.0.1" && ip_list[0] != ""] if var.nodes[k].machine_type == "controlplane" }
}

# output "node_info" {
#   description = "Complete node information"
#   value = {
#     vm_id        = proxmox_virtual_environment_vm.talos_node.id
#     name         = proxmox_virtual_environment_vm.talos_node.name
#     ip_address   = try(proxmox_virtual_environment_vm.talos_node.ipv4_addresses[0][0], var.ip_address != null ? var.ip_address : "DHCP-assigned")
#     role         = var.node_role
#     cpu_cores    = var.cpu_cores
#     memory_mb    = var.memory_mb
#     disk_size_gb = var.disk_size_gb
#   }
# }

# output "talos_node_endpoint" {
#   description = "Talos API endpoint for this node"
#   value       = try(proxmox_virtual_environment_vm.talos_node.ipv4_addresses[0][0], var.ip_address != null ? var.ip_address : "DHCP-assigned")
# }

# output "mac_address" {
#   description = "MAC address of the primary network interface"
#   value       = try(proxmox_virtual_environment_vm.talos_node.network_device[0].mac_address, "unknown")
# }
