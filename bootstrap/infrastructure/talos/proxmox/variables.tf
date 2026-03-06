variable "environment" {
  type = string
  default = "homelab"
}

variable "project" {
  type = string
  default = "talos"
}

variable "common_tags" {
  type    = list(string)
  default = ["k8s", "talos"]
}

variable "proxmox_node" {
  type = string
  default = "s1"
}

variable "template_vm_id" {
  type = number
  default = 9150
}

variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name                  = string
    endpoint              = string
    dns_servers           = optional(list(string), ["10.10.10.1"])
    gateway               = string
    talos_version         = string
    template_bridge       = optional(string, "vmbr0")
    template_vm_id        = optional(number, 9150)
    vm_storage_pool       = optional(string, "proxmox-nfs")
  })
}

variable "talos_image" {
  description = "Talos image configuration"
  type = object({
    extensions  = optional(list(string), [])
    kernelArgs  = optional(list(string), [])
  })
}

variable "k8s_addon_versions" {
  description = "Kubernetes addon versions"
  type = object({
    gateway_api      = string
  })
}

variable "nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    host_node       = string
    machine_type    = string
    datastore_id    = optional(string, "local-zfs")
    network_config  = map(object({
      mac_address   = string
      ip            = string
      bridge        = optional(string, "vmbr0")
      vlan          = optional(number, null)
    }))
    vm_id           = number
    cpu             = number
    ram_max         = number
    ram_min         = number
    update          = optional(bool, false)
    igpu            = optional(bool, false)
  }))
}
