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
      allowSchedulingOnControlPlanes = false
      network = {
        cni = {
          name = "none"
        }
      }
      proxy = {
        disabled = true
      }
      inlineManifests = [
        yamldecode(
          templatefile("${path.module}/proxmox-cloud-controller-manager.yaml",
            {
              proxmox_api              = var.proxmox_api,
              proxmox_csi_full_tokenid = var.proxmox_csi_full_tokenid,
              proxmox_csi_token_value  = var.proxmox_csi_token_value
          })
        ),
        yamldecode(templatefile("${path.module}/proxmox-csi-plugin.yaml",
          {
            proxmox_api              = var.proxmox_api,
            proxmox_csi_full_tokenid = var.proxmox_csi_full_tokenid,
            proxmox_csi_token_value  = var.proxmox_csi_token_value
          })
        )
      ]
      extraManifests = var.kubernetes_extra_manifests
      externalCloudProvider = {
        enabled = true
        manifests = [
          "https://raw.githubusercontent.com/sergelogvinov/proxmox-csi-plugin/main/docs/deploy/proxmox-csi-plugin.yml",
          "https://raw.githubusercontent.com/sergelogvinov/proxmox-cloud-controller-manager/main/docs/deploy/cloud-controller-manager.yml"
        ]
      }
    }
  }
}
