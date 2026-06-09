locals {
  nodes = merge(var.controlplanes, var.workers)
  common_machine_config = {
    machine = {
      time = {
        servers = var.talos.time_servers
      }
      features = {
        hostDNS = {
          enabled              = true
          resolveMemberNames   = true
          forwardKubeDNSToHost = false # https://github.com/siderolabs/talos/issues/10002
        }
      }
      certSANs = [
        for ip in local.nodes : ip.ip_addr
      ]
      install = {
        image = var.talos.image
        disk  = var.talos.vm_disk
      }
    }
    cluster = {
      allowSchedulingOnControlPlanes = false
      clusterName                    = var.talos.cluster_name
      network = {
        cni = {
          name = "none"
        }
      }
      proxy = {
        disabled = true
      }
      extraManifests = var.kubernetes_extra_manifests
      controllerManager = {
        extraArgs = {
          bind-address = "0.0.0.0"
        }
      }
      scheduler = {
        extraArgs = {
          bind-address = "0.0.0.0"
        }
      }
    }
  }
}
