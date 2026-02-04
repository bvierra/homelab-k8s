module "talos_vm" {
  source = "./modules/talos-vm"

  depends_on = [ module.talos_template ]

  template_vm_id = var.cluster.template_vm_id
  storage_pool   = var.cluster.vm_storage_pool
  dns_servers    = var.cluster.dns_servers
  gateway        = var.cluster.gateway

  common_tags     = var.common_tags
  nodes           = var.nodes
}
