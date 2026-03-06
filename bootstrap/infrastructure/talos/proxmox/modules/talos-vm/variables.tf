variable "template_vm_id" {
  type = number
  default = 9150
}

variable "storage_pool" {
  type    = string
  default = "proxmox-nfs"
}

variable "dns_servers" {
  type    = list(string)
  default = ["10.10.10.1"]
}

variable "gateway" {
  type    = string
  default = "10.10.130.1"
}

variable "common_tags" {
  type    = list(string)
  default = []
}

variable "nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    host_node       = string
    machine_type    = string
    datastore_id    = optional(string, null)
    network_config  = map(object({
      mac_address   = string
      ip            = string
      bridge        = string
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
