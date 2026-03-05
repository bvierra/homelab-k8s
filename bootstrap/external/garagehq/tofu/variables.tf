variable "host_node" {
  description = "The node that the VM will be created on"
  type        = string
  default     = "pve"
}

variable "name" {
  description = "The name of the VM"
  type        = string
  default     = "garagehq"
}

variable "description" {
  description = "The description to use for the VM"
  type        = string
  default     = "GarageHQ VM"
}

variable "tags" {
  description = "The tags to use for the VM"
  type        = list(any)
  default     = []
}

variable "id" {
  description = "The VMID to use for the VM"
  type        = number
  default     = null
}

variable "template_vmid" {
  description = "The VMID of the template that is used"
  type        = number
}

variable "template_node" {
  description = "The Proxmox node that the template VM lives on"
  type        = string
  default     = "pve"
}

variable "storage_pool" {
  description = "The Proxmox storage pool that the virtual hard disks will be saved to"
  type        = string
  default     = "local-lvm"
}

variable "dns_servers" {
  description = "The DNS servers to use for the VM"
  type        = list(any)
  default     = []
}

variable "gateway" {
  description = "The gateway to use for the VM (optional)"
  type        = string
  default     = null
}

variable "ip_address" {
  description = "The IP address to use for the VM (optional)"
  type        = string
  default     = null
}

variable "mac_address" {
  description = "The MAC address to use for the VM (optional)"
  type        = string
  default     = null
}

variable "network_bridge" {
  description = "The network bridge to use for the VM (optional)"
  type        = string
  default     = "vmbr0"
}

variable "network_vlan" {
  description = "The network VLAN to use for the VM (optional)"
  type        = number
  default     = null
}

variable "disk_size" {
  description = "The size of the disk to use for the VM (in GB)"
  type        = number
  default     = 10
}

variable "cpu_cores" {
  description = "The number of CPUs to use for the VM"
  type        = number
  default     = 2
}

variable "ram_dedicated" {
  description = "The minumum amount of RAM (in GB) to use for the VM"
  type        = number
  default     = 2
}

variable "ram_floating" {
  description = "The maximum amount of RAM (in GB) to use for the VM"
  type        = number
  default     = 1
}

variable "username" {
  description = "The username that will be created on the VM"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "The path of the public ssh key that will be added to the username that is created"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

