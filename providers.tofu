terraform {
  required_version = "~>1.8 "

  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc6"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.7.0"
    }
  }
}

provider "proxmox" {
  pm_tls_insecure = true
}
