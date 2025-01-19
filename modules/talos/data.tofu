data "talos_machine_configuration" "controlplanes" {
  cluster_name       = var.cluster_name
  machine_type       = "controlplane"
  cluster_endpoint   = "https://${var.controlplane_ips[0]}:6443"
  machine_secrets    = talos_machine_secrets.machine_secrets.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  examples           = false
  docs               = false
  config_patches = [
    yamlencode(local.common_machine_config)
  ]
}

# data "talos_machine_configuration" "workers" {
#   cluster_name       = var.cluster_name
#   machine_type       = "worker"
#   cluster_endpoint   = "https://${var.controlplane_ips[0]}:6443"
#   machine_secrets    = talos_machine_secrets.machine_secrets.machine_secrets
#   talos_version      = var.talos_version
#   kubernetes_version = var.kubernetes_version
#   examples           = false
#   docs               = false
# }

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints = [
    for ip in var.controlplane_ips : "https://${ip}:6443"
  ]
}
