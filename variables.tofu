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
    name      = string
    vmid      = number
    memory    = number
    cores     = number
    disk_size = number
    mac_addr  = string
  }))
  default = {
    controlplane1 = {
      name      = "k8s-controlplane-1"
      vmid      = 101
      memory    = 4096 # MiB
      cores     = 2
      disk_size = 10 # GiB
      mac_addr  = "AA:BB:CC:50:00:10"
    }
  }
}

variable "workers" {
  type = map(object({
    name      = string
    vmid      = number
    memory    = number
    cores     = number
    disk_size = number
    mac_addr  = string
  }))
  default = {
    worker1 = {
      name      = "k8s-worker-1"
      vmid      = 102
      memory    = 8192 # MiB
      cores     = 4
      disk_size = 100 # GiB
      mac_addr  = "AA:BB:CC:50:00:11"
    }
    worker2 = {
      name      = "k8s-worker-2"
      vmid      = 103
      memory    = 8192 # MiB
      cores     = 4
      disk_size = 100 # GiB
      mac_addr  = "AA:BB:CC:50:00:12"
    }
  }
}
