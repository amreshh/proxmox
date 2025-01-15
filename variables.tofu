variable "talos_version" {
  type        = string
  default     = "1.9.1"
  description = "Talos version"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.31.1"
  description = "Kubernetes version to provision"
}

variable "cluster_name" {
  type        = string
  default     = "talos"
  description = "Name of the kubernetes cluster"
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
  default = {
    controlplane1 = {
      proxmox_vm_name      = "k8s-controlplane-1"
      proxmox_vmid         = 101
      proxmox_vm_memory    = 4096 # MiB
      proxmox_vm_cores     = 2
      proxmox_vm_disk_size = 10 # GiB
      proxmox_vm_mac_addr  = "AA:BB:CC:50:00:10"
    }
  }
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
  default = {
    worker1 = {
      proxmox_vm_name      = "k8s-worker-1"
      proxmox_vmid         = 102
      proxmox_vm_memory    = 8192 # MiB
      proxmox_vm_cores     = 4
      proxmox_vm_disk_size = 100 # GiB
      proxmox_vm_mac_addr  = "AA:BB:CC:50:00:11"
    }
  }
}
