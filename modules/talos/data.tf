data "talos_machine_configuration" "controlplanes" {
  cluster_name       = var.talos.cluster_name
  machine_type       = "controlplane"
  cluster_endpoint   = "https://${var.controlplanes.controlplane1.ip_addr}:6443"
  machine_secrets    = talos_machine_secrets.machine_secrets.machine_secrets
  talos_version      = var.talos.version
  kubernetes_version = var.kubernetes_version
  examples           = false
  docs               = false
  config_patches = [
    yamlencode(local.common_machine_config)
  ]
}

data "talos_machine_configuration" "workers" {
  cluster_name       = var.talos.cluster_name
  machine_type       = "worker"
  cluster_endpoint   = "https://${var.controlplanes.controlplane1.ip_addr}:6443"
  machine_secrets    = talos_machine_secrets.machine_secrets.machine_secrets
  talos_version      = var.talos.version
  kubernetes_version = var.kubernetes_version
  examples           = false
  docs               = false
  config_patches = [
    yamlencode(local.common_machine_config)
  ]
}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.talos.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [var.controlplanes.controlplane1.ip_addr]
  nodes = [
    for ip in local.nodes : ip.ip_addr
  ]
}

data "talos_cluster_health" "talos_cluster_health" {
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  control_plane_nodes = [
    for k, v in var.controlplanes : v.ip_addr
  ]
  worker_nodes = [
    for k, v in var.workers : v.ip_addr
  ]
  endpoints = [var.controlplanes.controlplane1.ip_addr]

  timeouts = {
    read = "10m"
  }
}
