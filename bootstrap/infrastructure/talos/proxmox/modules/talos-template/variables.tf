variable "common_tags" {
  type    = list(string)
  default = []
}

variable "proxmox_node" {
  type = string
  default = "s1"
}

variable "proxmox_import_path" {
  type    = string
  default = "/mnt/pve/proxmox-nfs/import"
}

# variable "talos_schematic_id" {
#   type = string
#   default = "e3fab82b561b5e559cdf1c0b1e5950c0e52700b9208a2cfaa5b18454796f3a7e"
# }

variable "talos_version" {
  type = string
  default = "v1.12.1"
}

variable "talos_image" {
  description = "Talos image configuration"
  type = object({
    extensions  = optional(list(string), [])
    kernelArgs  = optional(list(string), [])
  })
}

variable "template_bridge" {
  type    = string
  default = "vmbr0"
}

variable "template_vm_id" {
  type = number
  default = 9150
}

variable "vm_storage_pool" {
  type    = string
  default = "proxmox-nfs"
}
