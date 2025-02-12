resource "talos_machine_secrets" "machine_secrets" {
  talos_version = var.talos.version
}

resource "talos_machine_configuration_apply" "controlplanes" {
  for_each                    = var.controlplanes
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplanes.machine_configuration
  endpoint                    = var.controlplanes.controlplane1.ip_addr
  node                        = var.controlplanes[each.key].ip_addr
}

resource "talos_machine_configuration_apply" "workers" {
  for_each                    = var.workers
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.workers.machine_configuration
  node                        = var.workers[each.key].ip_addr
}

resource "talos_machine_bootstrap" "talos" {
  for_each             = var.controlplanes
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoint             = each.value.ip_addr
  node                 = each.value.ip_addr

  depends_on = [
    talos_machine_configuration_apply.controlplanes
  ]
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoint             = var.controlplanes.controlplane1.ip_addr
  node                 = var.controlplanes.controlplane1.ip_addr

  depends_on = [
    talos_machine_bootstrap.talos
  ]
}

resource "helm_release" "cilium" {
  name            = "cilium"
  repository      = "https://helm.cilium.io/"
  version         = var.cilium_version
  chart           = "cilium"
  namespace       = "kube-system"
  atomic          = true
  cleanup_on_fail = true

  set = [
    {
      name  = "ipam.mode"
      value = "kubernetes"
    },
    {
      name  = "kubeProxyReplacement"
      value = "true"
    },
    {
      name  = "k8sServiceHost"
      value = "localhost"
    },
    {
      name  = "k8sServicePort"
      value = "7445"
    },
    {
      name  = "securityContext.capabilities.ciliumAgent"
      value = "{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}"
    },
    {
      name  = "securityContext.capabilities.cleanCiliumState"
      value = "{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"
    },
    {
      name  = "cgroup.autoMount.enabled"
      value = "false"
    },
    {
      name  = "cgroup.hostRoot"
      value = "/sys/fs/cgroup"
    },
    {
      name  = "gatewayAPI.enabled"
      value = "true"
    },
    {
      name  = "gatewayAPI.enableAlpn"
      value = "true"
    },
    {
      name  = "gatewayAPI.enableAppProtocol"
      value = "true"
    },
    {
      name  = "l2announcements.enabled"
      value = "true"
    },
    {
      name  = "prometheus.enabled"
      value = "true"
    },
    {
      name  = "operator.prometheus.enabled"
      value = "true"
    },
    {
      name  = "hubble.relay.enabled"
      value = "true"
    },
    {
      name  = "hubble.ui.enabled"
      value = "true"
    },
    {
      name  = "hubble.metrics.enableOpenMetrics"
      value = "true"
    },
    {
      name  = "hubble.metrics.enabled"
      value = "{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\\,source_namespace\\,source_workload\\,destination_ip\\,destination_namespace\\,destination_workload\\,traffic_direction}"
    },
    {
      name  = "hubble.metrics.serviceMonitor.enabled"
      value = "false" # need to do this after monitoring stack is installed with the crds
    }
  ]

  depends_on = [
    data.http.kubernetes_health
  ]
}

# resource "flux_bootstrap_git" "flux_gitops_repo" {
#   embedded_manifests   = true
#   path                 = "flux"
#   delete_git_manifests = false
#   kustomization_override = templatefile("${path.module}/flux-kustomization-patch.yaml",
#     {
#       branch = "dev"
#   })

#   depends_on = [
#     helm_release.cilium
#   ]
# }

resource "kubernetes_namespace" "flux2" {
  metadata {
    name = "flux-system"
  }
}

resource "helm_release" "flux2" {
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  version    = "2.14.1"
  name       = "flux2"
}

resource "helm_release" "flux2_sync" {
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2-sync"
  version    = "1.10.0"
  name       = "flux-system"
  namespace  = "flux-system"

  set = [
    {
      name  = "gitRepository.spec.url"
      value = "https://fluxcd:${var.github_token}@github.com/amreshh/proxmox.git"
    },
    {
      name  = "gitRepository.spec.ref.branch"
      value = "dev"
    },
    {
      name  = "kustomize.spec.path"
      value = "flux"
    }
  ]
}

resource "local_sensitive_file" "kubeconfig_file" {
  content         = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  filename        = "/root/.kube/config"
  file_permission = "0711"
}

resource "local_sensitive_file" "talosconfig_file" {
  content         = data.talos_client_configuration.talosconfig.talos_config
  filename        = "/root/.talos/config"
  file_permission = "0600"
}

