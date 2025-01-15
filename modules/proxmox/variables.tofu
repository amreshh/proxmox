variable "controlplanes" {
  type = map(object({
    proxmox_vm_name      = string
    proxmox_vmid         = number
    proxmox_vm_memory    = number
    proxmox_vm_cores     = number
    proxmox_vm_disk_size = number
    proxmox_vm_mac_addr  = string
  }))
}

variable "workers" {
  type = map(object({
    proxmox_vm_name      = string
    proxmox_vmid         = number
    proxmox_vm_memory    = number
    proxmox_vm_cores     = number
    proxmox_vm_disk_size = number
    proxmox_vm_mac_addr  = string
  }))
}
