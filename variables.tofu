variable "talos_version" {
  type        = string
  default     = "1.9.3"
  description = "Talos version"
}

variable "talos_image" {
  type        = string
  default     = "factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.9.3"
  description = "Talos image to use"
}

variable "github_token" {
  type        = string
  description = "GitHub token"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.32.0"
  description = "Kubernetes version to provision"
}

variable "kubernetes_extra_manifests" {
  type = list(string)
  default = [
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml"
  ]
  description = "Extra kubernetes manifest to apply"
}

variable "cilium_version" {
  type        = string
  default     = "1.17.0"
  description = "Cilium version to provision"
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
  default = {
    controlplane1 = {
      cluster_name = "talos"
      name         = "k8s-controlplane-1"
      vm_id        = 101
      memory       = 4096 # MiB
      cores        = 2
      disk_size    = 10 # GiB
      mac_addr     = "00:00:00:00:00:01"
      ip_addr      = "192.168.1.4"
    }
  }
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
  default = {
    worker1 = {
      cluster_name = "talos"
      name         = "k8s-worker-1"
      vm_id        = 102
      memory       = 8192 # MiB
      cores        = 4
      disk_size    = 100 # GiB
      mac_addr     = "00:00:00:00:00:02"
      ip_addr      = "192.168.1.5"
    }
    worker2 = {
      cluster_name = "talos"
      name         = "k8s-worker-2"
      vm_id        = 103
      memory       = 8192 # MiB
      cores        = 4
      disk_size    = 100 # GiB
      mac_addr     = "00:00:00:00:00:03"
      ip_addr      = "192.168.1.6"
    }
  }
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
