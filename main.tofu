module "proxmox" {
  source        = "./modules/proxmox"
  controlplanes = var.controlplanes
  workers       = var.workers
}

# module "talos" {
#   source             = "./modules/talos"
#   talos_version      = var.talos_version
#   kubernetes_version = var.kubernetes_version
#   controlplane_ips   = module.proxmox.controlplane_ips
#   worker_ips         = module.proxmox.worker_ips
# }
