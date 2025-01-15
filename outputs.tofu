output "controlplane_ips" {
  value = module.proxmox.controlplane_ips
}

output "worker_ips" {
  value = module.proxmox.worker_ips
}
