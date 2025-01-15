variable "talos_version" {
  type        = string
  description = "Talos version"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to provision"
}

variable "cluster_name" {
  type        = string
  default     = "talos"
  description = "Name of the kubernetes cluster"
}

variable "controlplane_ips" {
  type        = string
  description = "List of controlplane IPs"
}

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
