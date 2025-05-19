variable "talos" {
  type = object({
    version = string
    iso     = string
    image   = string
  })
  default = {
    version = "1.10.2"
    iso     = "local:iso/talos_1.10.2.iso"
    image   = "factory.talos.dev/metal-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.10.2"
  }
}

variable "github_token" {
  type        = string
  description = "GitHub token"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.33.1"
  description = "Kubernetes version to provision"
}

variable "kubernetes_extra_manifests" {
  type = list(string)
  default = [
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.1/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.1/config/crd/standard/gateway.networking.k8s.io_gateways.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.1/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.1/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.1/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.1/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml"
  ]
  description = "Extra kubernetes manifest to apply"
}

variable "cilium_version" {
  type        = string
  default     = "1.17.4"
  description = "Cilium version to provision"
}

variable "flux_version" {
  type = object({
    version      = string
    sync_version = string
  })
  default = {
    version      = "2.15.0"
    sync_version = "1.12.0"
  }
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
