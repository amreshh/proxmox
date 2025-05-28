output "controlplane_ips" {
  value = setsubtract(flatten([
    for ip in proxmox_virtual_environment_vm.controlplanes : ip.ipv4_addresses
  ]), ["127.0.0.1"])
}

output "worker_ips" {
  value = setsubtract(flatten([
    for ip in proxmox_virtual_environment_vm.workers : ip.ipv4_addresses
  ]), ["127.0.0.1"])
}
