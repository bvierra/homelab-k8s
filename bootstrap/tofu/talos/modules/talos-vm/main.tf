terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.93.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

resource "proxmox_virtual_environment_vm" "talos_node" {
  for_each      = var.nodes

  node_name     = each.value.host_node
  name          = each.key

  description   = each.value.machine_type == "controlplane" ? "Talos Control Plane" : "Talos Worker"
  tags          = each.value.machine_type == "controlplane" ? concat(var.common_tags, ["controlplane"]) : concat(var.common_tags, ["worker"])

  vm_id         = each.value.vm_id

  machine       = "q35"
  scsi_hardware = "virtio-scsi-pci"

  bios          = "seabios"
  stop_on_destroy = true
  clone {
    vm_id       = var.template_vm_id
    node_name   = "s1"
    full        = true
    retries     = 3
  }

  disk {
    interface     = "scsi0"
    size          = 10
    ssd           = true
    datastore_id  = var.storage_pool
    file_format   = "qcow2"
  }

  initialization {
    datastore_id = var.storage_pool
    file_format  = "qcow2"
    dns {
      servers    = var.dns_servers
    }
    ip_config {
      ipv4 {
        address = "${each.value.network_config["net0"].ip}/24"
        gateway = var.gateway
      }
    }
    ip_config {
      ipv4 {
        address = "${each.value.network_config["net1"].ip}/24"
      }
    }
  }

  network_device {
    mac_address = each.value.network_config["net0"].mac_address
    model       = "virtio"
    bridge      = each.value.network_config["net0"].bridge
    vlan_id     = each.value.network_config["net0"].vlan
  }

  network_device {
    mac_address = each.value.network_config["net1"].mac_address
    model       = "virtio"
    bridge      = each.value.network_config["net1"].bridge
    vlan_id     = each.value.network_config["net1"].vlan
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores = each.value.cpu
    type  = "host"
  }

  memory {
    dedicated   = each.value.ram_max * 1024
    floating    = each.value.ram_min * 1024
  }

  agent {
    enabled = true
  }

}

# resource "proxmox_virtual_environment_haresource" "talos_node" {
#   depends_on = [ proxmox_virtual_environment_vm.talos_node ]
#   for_each     = var.nodes
#   resource_id  = "vm:${each.value.vm_id}"
#   group        = each.value.host_node
#   state        = "started"
#   comment      = "Managed by Terraform"
# }
