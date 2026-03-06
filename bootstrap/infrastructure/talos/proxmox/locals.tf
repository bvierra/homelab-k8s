locals {
  common_tags = ["k8s", "talos"]
  vm_cp_ips   = [ for k, v in var.nodes : v.network_config["net0"].ip if v.machine_type == "controlplane" ]
}
