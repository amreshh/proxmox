locals {
  nodes = merge(var.controlplanes, var.workers)
  common_machine_config = {
    machine = {
      certSANs = [
        for ip in local.nodes : ip.ip_addr
      ]
      install = {
        image = var.talos_image
      }
    }
    cluster = {
      allowSchedulingOnControlPlanes = true
      network = {
        cni = {
          name = "none"
        }
      }
      proxy = {
        disabled = true
      }
      extraManifests = var.kubernetes_extra_manifests
      externalCloudProvider = {
        enabled = true
        manifests = [
          "https://raw.githubusercontent.com/sergelogvinov/proxmox-csi-plugin/main/docs/deploy/proxmox-csi-plugin.yml"
        ]
      }
    }
  }
}
