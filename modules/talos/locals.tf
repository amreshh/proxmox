locals {
  nodes = merge(var.controlplanes, var.workers)

  common_patches = [
    yamlencode({
      machine = {
        certSANs = [for n in local.nodes : n.ip_addr]
      }
    }),
    yamlencode({
      apiVersion = "v1alpha1"
      kind : "TimeSyncConfig"
      ntp = {
        servers = var.talos.time_servers
      }
    }),
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "ResolverConfig"
      hostDNS = {
        enabled              = true
        resolveMemberNames   = true
        forwardKubeDNSToHost = false # https://github.com/siderolabs/talos/issues/10002
      }
    }),
    yamlencode({
      apiVersion = "v1alpha1"
      kind       = "UnattendedInstallConfig"
      installer = {
        image = var.talos.image
      }
      provisioning = {
        diskSelector = {
          match = "disk.dev_path == \"${var.talos.vm_disk}\""
        }
      }
    })
  ]

  controlplane_patches = concat(
    [
      yamlencode({
        apiVersion = "v1alpha1"
        kind       = "KubeControllerManagerConfig"
        extraArgs  = { "bind-address" = "0.0.0.0" }
      }),
      yamlencode({
        apiVersion = "v1alpha1"
        kind       = "KubeSchedulerConfig"
        extraArgs  = { "bind-address" = "0.0.0.0" }
      }),
      yamlencode({
        apiVersion = "v1alpha1"
        kind       = "KubeProxyConfig"
        enabled    = false
      }),
      yamlencode({
        apiVersion = "v1alpha1"
        kind       = "KubeFlannelCNIConfig"
        "$patch"   = "delete"
      })
    ],
    [
      for i, url in var.kubernetes_extra_manifests : yamlencode({
        apiVersion = "v1alpha1"
        kind       = "KubeExternalManifestConfig"
        name       = "extra-manifest-${i}"
        url        = url
      })
    ]
  )
}
