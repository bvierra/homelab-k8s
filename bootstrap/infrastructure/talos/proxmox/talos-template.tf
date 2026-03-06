module "talos_template" {
  source = "./modules/talos-template"

  common_tags           = concat(local.common_tags, ["template"])

  proxmox_node          = var.proxmox_node
  #talos_schematic_id    = var.cluster.talos_schematic_id
  talos_image           = var.talos_image
  talos_version         = var.cluster.talos_version
  template_bridge       = var.cluster.template_bridge
  template_vm_id        = var.cluster.template_vm_id
  vm_storage_pool       = var.cluster.vm_storage_pool
}

output "schematic_id" {
  value = module.talos_template.schematic_id
}
