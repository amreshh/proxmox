module "proxmox" {
  source        = "./modules/proxmox"
  controlplanes = var.controlplanes
  workers       = var.workers
}

module "talos" {
  source                     = "./modules/talos"
  talos_version              = var.talos_version
  talos_image                = var.talos_image
  kubernetes_version         = var.kubernetes_version
  kubernetes_extra_manifests = var.kubernetes_extra_manifests
  cilium_version             = var.cilium_version
  controlplanes              = var.controlplanes
  workers                    = var.workers
  proxmox_api                = var.proxmox_api
  proxmox_csi_full_tokenid   = var.proxmox_csi_full_tokenid
  proxmox_csi_token_value    = var.proxmox_csi_token_value

  depends_on = [
    module.proxmox
  ]
}
