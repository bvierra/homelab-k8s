# output "vm_id" {
#   value = module.talos_vm.vm_id
# }

# output "vm_name" {
#   value = module.talos_vm.name
# }

# output "vm_node_mapping" {
#   value = module.talos_vm.vm_node_mapping
# }

# output "vm_ip_addresses" {
#   value = module.talos_vm.ip_addresses
# }

# output "vm_ip_address" {
#   value = module.talos_vm.ip_address
# }

# output "vm_cp_ip_addresses" {
#   value = module.talos_vm.cp_ip_addresses
# }

# output "vm_cp_ips" {
#   value = [ for k, v in var.nodes : v.network_config["net0"].ip if v.machine_type == "controlplane" ]
# }

