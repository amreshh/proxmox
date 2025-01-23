variable "talos_version" {
  type        = string
  description = "Talos version"
}

variable "talos_image" {
  type        = string
  description = "Talos image to use"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to provision"
}

variable "cilium_version" {
  type        = string
  description = "Cilium version to provision"
}

variable "cluster_name" {
  type        = string
  default     = "talos"
  description = "Name of the kubernetes cluster"
}

variable "controlplanes" {
  type = map(object({
    name      = string
    vm_id     = number
    memory    = number
    cores     = number
    disk_size = number
    mac_addr  = string
    ip_addr   = string
  }))
}

variable "workers" {
  type = map(object({
    name      = string
    vm_id     = number
    memory    = number
    cores     = number
    disk_size = number
    mac_addr  = string
    ip_addr   = string
  }))
}
