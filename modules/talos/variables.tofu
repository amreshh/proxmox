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
  type        = list(string)
  description = "List of controlplane IPs"
}

variable "worker_ips" {
  type        = list(string)
  description = "List of worker IPs"
}
