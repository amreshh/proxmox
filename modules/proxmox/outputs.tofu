output "controlplane_ips" {
  value = [for ip in proxmox_vm_qemu.controlplanes : ip.default_ipv4_address]
}

output "worker_ips" {
  value = [for ip in proxmox_vm_qemu.workers : ip.default_ipv4_address]
}
