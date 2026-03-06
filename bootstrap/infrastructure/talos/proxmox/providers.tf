terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "~> 0.98.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
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


