locals {
  nodes = merge(var.controlplanes, var.workers)
  common_machine_config = {
    machine = {
      certSANs = [
        for ip in local.nodes : ip.ip_addr
      ]
      install = {
        image = var.talos.image
      }
    }
    cluster = {
      allowSchedulingOnControlPlanes = false
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
