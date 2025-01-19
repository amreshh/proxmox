resource "talos_machine_secrets" "machine_secrets" {
  talos_version = var.talos_version
}

resource "talos_machine_configuration_apply" "controlplanes" {
  count                       = length(var.controlplane_ips)
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplanes.machine_configuration
  endpoint                    = var.controlplane_ips[0]
  node                        = var.controlplane_ips[count.index]
  config_patches = [
    yamlencode(local.common_machine_config)
  ]
}

# resource "talos_machine_configuration_apply" "workers" {
#   count                       = length(var.worker_ips)
#   client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
#   machine_configuration_input = data.talos_machine_configuration.workers.machine_configuration
#   endpoint                    = var.controlplane_ips[0]
#   node                        = var.worker_ips[count.index]
#   config_patches = [
#     yamlencode(local.common_machine_config)
#   ]
# }

# resource "talos_machine_configuration_apply" "workers" {
#   client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
#   machine_configuration_input = data.talos_machine_configuration.workers.machine_configuration
#   # endpoint                    = "192.168.1.45"
#   node = "192.168.1.47"
#   config_patches = [
#     yamlencode(local.common_machine_config)
#   ]
# }

resource "talos_machine_bootstrap" "talos" {
  count                = length(var.controlplane_ips)
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoint             = var.controlplane_ips[0]
  node                 = var.controlplane_ips[count.index]

  depends_on = [
    talos_machine_configuration_apply.controlplanes
  ]
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoint             = var.controlplane_ips[0]
  node                 = var.controlplane_ips[0]

  depends_on = [
    talos_machine_bootstrap.talos
  ]
}

resource "local_file" "kubeconfig_file" {
  content         = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  filename        = "/root/.kube/config"
  file_permission = "0711"
}

resource "local_file" "talosconfig_file" {
  content         = data.talos_client_configuration.talosconfig.talos_config
  filename        = "/root/.talos/config"
  file_permission = "0600"
}
