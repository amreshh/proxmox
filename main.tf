module "proxmox" {
  source        = "./modules/proxmox"
  controlplanes = var.controlplanes
  workers       = var.workers
  talos         = var.talos
}

module "talos" {
  source                     = "./modules/talos"
  talos                      = var.talos
  github_token               = var.github_token
  kubernetes_version         = var.kubernetes_version
  kubernetes_extra_manifests = var.kubernetes_extra_manifests
  cilium_version             = var.cilium_version
  flux_version               = var.flux_version
  controlplanes              = var.controlplanes
  workers                    = var.workers

  depends_on = [
    module.proxmox
  ]
}
