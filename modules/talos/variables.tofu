variable "talos" {
  type = object({
    version = string
    iso     = string
    image   = string
  })
}

variable "github_token" {
  type        = string
  description = "GitHub token"
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

variable "flux_version" {
  type = object({
    version      = string
    sync_version = string
  })
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

variable "proxmox_api" {
  type        = string
  description = "Proxmox api url"
}

variable "proxmox_csi_full_tokenid" {
  type        = string
  description = "Token id of the proxmox csi user"
}

variable "proxmox_csi_token_value" {
  type        = string
  description = "Token value of the proxmox csi user"
}
