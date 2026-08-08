# module "proxmox" {
#   source        = "./modules/proxmox"
#   controlplanes = var.controlplanes
#   workers       = var.workers
#   talos         = var.talos
# }

module "talos" {
  source                     = "./modules/talos"
  talos                      = local.env.talos
  github_token               = var.github_token
  age_key                    = var.age_key
  kubernetes_version         = local.env.kubernetes_version
  kubernetes_extra_manifests = local.env.kubernetes_extra_manifests
  cilium_version             = local.env.cilium_version
  flux_version               = local.env.flux_version
  controlplanes              = local.env.controlplanes
  workers                    = local.env.workers

  # depends_on = [
  #   module.proxmox
  # ]
}
