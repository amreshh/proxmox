resource "talos_machine_secrets" "machine_secrets" {
  talos_version = var.talos_version
}

resource "talos_machine_configuration_apply" "controlplanes" {
  count                       = length(var.controlplane_ips)
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplanes.machine_configuration
  node                        = var.controlplane_ips[count.index]
  config_patches = [
    yamlencode(local.common_machine_config)
  ]
}

resource "talos_machine_configuration_apply" "workers" {
  count                       = length(var.worker_ips)
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.workers[count.index].machine_configuration
  node                        = var.worker_ips[count.index]
  config_patches = [
    yamlencode(local.common_machine_config)
  ]
}

resource "talos_machine_bootstrap" "talos" {
  count                = length(var.controlplane_ips)
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.controlplane_ips[count.index]

  depends_on = [
    talos_machine_configuration_apply.controlplanes,
    talos_machine_configuration_apply.workers
  ]
}
