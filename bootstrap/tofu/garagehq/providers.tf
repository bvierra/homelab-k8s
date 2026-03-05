terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.97.0"
    }
  }
}

provider "proxmox" {
  insecure = true
  ssh {
    agent       = false
    private_key = file("~/.ssh/id_ed25519")
    username    = "root"
  }
}
