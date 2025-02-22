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
  lint            = true

  set {
    name  = "ipam.mode"
    value = "kubernetes"
  }
  set {
    name  = "kubeProxyReplacement"
    value = "true"
  }
  set {
    name  = "k8sServiceHost"
    value = "localhost"
  }
  set {
    name  = "k8sServicePort"
    value = "7445"
  }
  set {
    name  = "securityContext.capabilities.ciliumAgent"
    value = "{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}"
  }
  set {
    name  = "securityContext.capabilities.cleanCiliumState"
    value = "{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}"
  }
  set {
    name  = "cgroup.autoMount.enabled"
    value = "false"
  }
  set {
    name  = "cgroup.hostRoot"
    value = "/sys/fs/cgroup"
  }
  set {
    name  = "gatewayAPI.enabled"
    value = "true"
  }
  set {
    name  = "gatewayAPI.enableAlpn"
    value = "true"
  }
  set {
    name  = "gatewayAPI.enableAppProtocol"
    value = "true"
  }
  set {
    name  = "l2announcements.enabled"
    value = "true"
  }
  set {
    name  = "prometheus.enabled"
    value = "true"
  }
  set {
    name  = "operator.prometheus.enabled"
    value = "true"
  }
  set {
    name  = "hubble.relay.enabled"
    value = "true"
  }
  set {
    name  = "hubble.ui.enabled"
    value = "true"
  }
  set {
    name  = "hubble.metrics.enableOpenMetrics"
    value = "true"
  }
  set {
    name  = "hubble.metrics.enabled"
    value = "{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\\,source_namespace\\,source_workload\\,destination_ip\\,destination_namespace\\,destination_workload\\,traffic_direction}"
  }
  set {
    name  = "hubble.metrics.serviceMonitor.enabled"
    value = "false" # need to do this after monitoring stack is installed with the crds
  }

  depends_on = [
    data.http.kubernetes_health
  ]
}

resource "helm_release" "flux2" {
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  version          = var.flux_version.version
  name             = "flux2"
  namespace        = "flux-system"
  create_namespace = true
  atomic           = true
  cleanup_on_fail  = true
  lint             = true

  set {
    name  = "imageReflectionController.create"
    value = "false"
  }
  set {
    name  = "imageAutomationController.create"
    value = "false"
  }

  depends_on = [
    helm_release.cilium
  ]
}

resource "kubernetes_secret" "github_token" {
  metadata {
    name      = "github-token"
    namespace = helm_release.flux2.namespace
  }
  data = {
    username = "fluxcd"
    password = var.github_token
  }
}

resource "helm_release" "flux2_sync" {
  repository      = "https://fluxcd-community.github.io/helm-charts"
  chart           = "flux2-sync"
  version         = var.flux_version.sync_version
  name            = "flux-system"
  namespace       = helm_release.flux2.namespace
  atomic          = true
  cleanup_on_fail = true
  lint            = true

  set {
    name  = "gitRepository.spec.url"
    value = "https://github.com/amreshh/proxmox.git"
  }
  set {
    name  = "gitRepository.spec.ref.branch"
    value = "dev"
  }
  set {
    name  = "gitRepository.spec.secretRef.name"
    value = kubernetes_secret.github_token.metadata[0].name
  }
  set {
    name  = "kustomization.spec.path"
    value = "flux"
  }

  depends_on = [
    helm_release.flux2
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

