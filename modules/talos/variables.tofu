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

variable "kubernetes_extra_manifests" {
  type        = list(string)
  description = "Kubernetes Gateway API version to provision"
}

variable "cilium_version" {
  type        = string
  description = "Cilium version to provision"
}

variable "cilium_lb_ip_pool" {
  type        = string
  description = "Cilium load balancer IP pool"
}

variable "controlplanes" {
  type = map(object({
    cluster_name = string
    name         = string
    vm_id        = number
    memory       = number
    cores        = number
    disk_size    = number
    mac_addr     = string
    ip_addr      = string
  }))
}

variable "workers" {
  type = map(object({
    cluster_name = string
    name         = string
    vm_id        = number
    memory       = number
    cores        = number
    disk_size    = number
    mac_addr     = string
    ip_addr      = string
  }))
}
