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
      name  = "policyEnforcementMode"
      value = "always"
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
      name  = "hubble.metrics.serviceMonitor.enabled"
      value = "false" # need to set this to true after monitoring stack is installed with the crds
    },
  ]

  set_list = [
    {
      name = "hubble.metrics.enabled"
      value = [
        "dns",
        "drop",
        "tcp",
        "httpV2",
        "icmp",
        "port-distribution",
        "flow:sourceContext=workload|dns|ip;destinationContext=workload|dns|ip",
      ]
    }
  ]

  depends_on = [
    data.talos_cluster_health.talos_cluster_health
  ]
}

resource "kubernetes_namespace_v1" "flux_system" {
  metadata {
    name = "flux-system"
  }
}

resource "helm_release" "flux2" {
  repository      = "https://fluxcd-community.github.io/helm-charts"
  chart           = "flux2"
  version         = var.flux_version.version
  name            = "flux2"
  namespace       = kubernetes_namespace_v1.flux_system.metadata[0].name
  atomic          = true
  cleanup_on_fail = true
  lint            = true

  set = [
    { name  = "imageReflectionController.create"
      value = "false"
    },
    {
      name  = "imageAutomationController.create"
      value = "false"
    },
    {
      name  = "policies.create"
      value = "false"
    },
    {
      name  = "helmController.annotations.k8s\\.grafana\\.com/scrape"
      value = "true"
      type  = "string"
    },
    {
      name  = "kustomizeController.annotations.k8s\\.grafana\\.com/scrape"
      value = "true"
      type  = "string"
    },
    {
      name  = "notificationController.annotations.k8s\\.grafana\\.com/scrape"
      value = "true"
      type  = "string"
    },
    {
      name  = "sourceController.annotations.k8s\\.grafana\\.com/scrape"
      value = "true"
      type  = "string"
    },
    {
      name  = "crds.annotations.k8s\\.grafana\\.com/scrape"
      value = "true"
      type  = "string"
    }
  ]

  depends_on = [
    helm_release.cilium
  ]
}

resource "kubernetes_secret_v1" "github_token" {
  metadata {
    name      = "github-token"
    namespace = kubernetes_namespace_v1.flux_system.metadata[0].name
  }
  data = {
    username = "fluxcd"
    password = var.github_token
  }
  type = "kubernetes.io/basic-auth"
}

resource "helm_release" "flux2_sync" {
  repository      = "https://fluxcd-community.github.io/helm-charts"
  chart           = "flux2-sync"
  version         = var.flux_version.sync_version
  name            = "flux-system"
  namespace       = kubernetes_namespace_v1.flux_system.metadata[0].name
  atomic          = true
  cleanup_on_fail = true
  lint            = true

  set = [
    {
      name  = "gitRepository.spec.url"
      value = "https://github.com/amreshh/proxmox.git"
    },
    {
      name  = "gitRepository.spec.ref.branch"
      value = terraform.workspace == "prd" ? "main" : "dev"
    },
    {
      name  = "gitRepository.spec.secretRef.name"
      value = kubernetes_secret_v1.github_token.metadata[0].name
    },
    {
      name  = "kustomization.spec.path"
      value = "flux/clusters/${terraform.workspace}"
    }
  ]

  depends_on = [
    helm_release.flux2
  ]
}

resource "kubernetes_secret_v1" "age_key" {
  metadata {
    name      = "age-key"
    namespace = kubernetes_namespace_v1.flux_system.metadata[0].name
  }
  data = {
    "age.agekey" = var.age_key
  }
  type = "Opaque"
}

resource "kubectl_manifest" "clusterwide_network_policy_allow_health_checks" {
  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2"
    kind       = "CiliumClusterwideNetworkPolicy"
    metadata = {
      name = "allow-cilium-health-checks"
    }
    spec = {
      endpointSelector = {
        matchLabels = {
          "reserved:health" = ""
        }
      }
      ingress = [
        {
          fromEntities = ["remote-node"]
        }
      ]
      egress = [
        {
          toEntities = ["remote-node"]
        }
      ]
    }
  })
}

resource "kubectl_manifest" "clusterwide_network_policy_allow_dns" {
  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2"
    kind       = "CiliumClusterwideNetworkPolicy"
    metadata = {
      name = "allow-dns"
    }
    spec = {
      description = "allow coredns to receive dns ingress requests and egress to talos upstream dns and kube-apiserver"
      endpointSelector = {
        matchLabels = {
          "k8s:io.kubernetes.pod.namespace" = "kube-system"
          "k8s:k8s-app"                     = "kube-dns"
        }
      }
      ingress = [
        {
          fromEndpoints = [
            {
              matchLabels = {}
            }
          ]
          toPorts = [
            {
              ports = [
                {
                  port     = "53"
                  protocol = "UDP"
                }
              ]
            }
          ]
        }
      ]
      egress = [
        {
          toEntities = ["kube-apiserver"]
          toPorts = [
            {
              ports = [
                {
                  port     = "6443"
                  protocol = "TCP"
                }
              ]
            }
          ]
        },
        {
          toCIDR = var.talos.dns_servers
          toPorts = [
            {
              ports = [
                {
                  port     = "53"
                  protocol = "UDP"
                }
              ]
            }
          ]
        }
      ]
    }
  })
}

resource "kubectl_manifest" "clusterwide_network_policy_allow_egress_dns" {
  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2"
    kind       = "CiliumClusterwideNetworkPolicy"
    metadata = {
      name = "allow-egress-to-kube-dns"
    }
    spec = {
      description      = "allow dns egress for all pods"
      endpointSelector = {}
      egress = [
        {
          toEndpoints = [
            {
              matchLabels = {
                "k8s:io.kubernetes.pod.namespace" = "kube-system"
                "k8s:k8s-app"                     = "kube-dns"

              }
            }
          ]
          toPorts = [
            {
              ports = [
                {
                  port     = "53"
                  protocol = "UDP"
                }
              ]
              rules = {
                dns = [
                  {
                    matchPattern = "*"
                  }
                ]
              }
            }
          ]
        }
      ]
    }
  })
}

resource "kubectl_manifest" "network_policy_allow_gitops_repo" {
  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2"
    kind       = "CiliumNetworkPolicy"
    metadata = {
      name      = "allow-egress-to-gitops-repo"
      namespace = kubernetes_namespace_v1.flux_system.metadata[0].name
    }
    spec = {
      description = "allow egress to gitops repo"
      endpointSelector = {
        matchLabels = {
          "k8s:io.kubernetes.pod.namespace" = kubernetes_namespace_v1.flux_system.metadata[0].name
          "k8s:app"                         = "source-controller"
        }
      }
      egress = [
        {
          toFQDNs = [
            { matchName = "github.com" }
          ]
          toPorts = [
            {
              ports = [
                {
                  port = "443"
                }
              ]
            }
          ]
        }
      ]
    }
  })
}

resource "kubectl_manifest" "network_policy_allow_flux" {
  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2"
    kind       = "CiliumNetworkPolicy"
    metadata = {
      name      = "allow-flux-internal-kube-apiserver"
      namespace = kubernetes_namespace_v1.flux_system.metadata[0].name
    }
    spec = {
      description      = "allow flux pods to access each other and kube-apiserver"
      endpointSelector = {}
      ingress = [
        {
          fromEndpoints = [
            {
              matchLabels = {
                "k8s:io.kubernetes.pod.namespace" = kubernetes_namespace_v1.flux_system.metadata[0].name
              }
              matchExpressions = [
                {
                  key      = "k8s:app"
                  operator = "In"
                  values = [
                    "source-controller",
                    "kustomize-controller",
                    "notification-controller",
                    "helm-controller"
                  ]
                }
              ]
            }
          ]
        }
      ]
      egress = [
        {
          toEndpoints = [
            {
              matchLabels = {
                "k8s:io.kubernetes.pod.namespace" = kubernetes_namespace_v1.flux_system.metadata[0].name
              }
              matchExpressions = [
                {
                  key      = "k8s:app"
                  operator = "In"
                  values = [
                    "source-controller",
                    "kustomize-controller",
                    "notification-controller",
                    "helm-controller"
                  ]
                }
              ]

            }
          ]
        },
        {
          toEntities = ["kube-apiserver"]
          toPorts = [
            {
              ports = [
                {
                  port     = "6443"
                  protocol = "TCP"
                }
              ]
            }
          ]
        }
      ]
    }
  })
}

resource "local_sensitive_file" "kubeconfig_file" {
  content         = talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  filename        = pathexpand("~/.kube/${terraform.workspace}_config")
  file_permission = "0600"
}

resource "local_sensitive_file" "talosconfig_file" {
  content         = data.talos_client_configuration.talosconfig.talos_config
  filename        = pathexpand("~/.talos/${terraform.workspace}_config")
  file_permission = "0600"
}

