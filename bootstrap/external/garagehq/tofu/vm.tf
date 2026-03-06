locals {
  ip_cidr_notation = var.ip_address != null ? "${var.ip_address}/24" : "dhcp"
}

data "local_file" "ssh_public_key" {
  filename = var.ssh_public_key
}

resource "proxmox_virtual_environment_vm" "vm" {
  node_name = var.host_node
  name      = var.name

  description = var.description
  tags        = var.tags

  vm_id = var.id

  machine       = "q35"
  scsi_hardware = "virtio-scsi-pci"

  bios            = "seabios"
  stop_on_destroy = true
  clone {
    vm_id     = var.template_vmid
    node_name = var.template_node
    full      = true
    retries   = 3
  }

  disk {
    size = var.disk_size
    interface = "virtio0"
    file_format = "qcow2"
    datastore_id  = var.storage_pool
  }

  initialization {
    datastore_id = var.storage_pool
    file_format  = "qcow2"
    dns {
      servers = var.dns_servers
    }
    ip_config {
      ipv4 {
        address = local.ip_cidr_notation
        gateway = var.gateway
      }
    }
    user_account {
      username = var.username
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }
  }

  network_device {
    mac_address = var.mac_address
    model       = "virtio"
    bridge      = var.network_bridge
    vlan_id     = var.network_vlan
  }

  operating_system {
    type = "l26"
  }

  cpu {
    cores = var.cpu_cores
    type  = "host"
  }

  memory {
    dedicated = var.ram_dedicated * 1024
    floating  = var.ram_floating * 1024
  }

  agent {
    enabled = true
  }

}
