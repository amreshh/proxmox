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

  depends_on = [
    module.proxmox
  ]
}
