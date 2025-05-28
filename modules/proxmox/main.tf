resource "proxmox_virtual_environment_vm" "controlplanes" {
  for_each      = var.controlplanes
  name          = each.value.name
  description   = "kubernetes controlplane"
  tags          = ["kubernetes", "controlplane"]
  node_name     = "proxmox"
  vm_id         = each.value.vm_id
  on_boot       = false
  boot_order    = ["scsi0", "ide2"]
  tablet_device = false
  bios          = "seabios"

  operating_system {
    type = "l26"
  }
  agent {
    enabled = true
  }
  cpu {
    cores = each.value.cores
    type  = "host"
  }
  memory {
    dedicated = each.value.memory
    floating  = each.value.memory
  }
  disk {
    datastore_id = "local-zfs"
    backup       = false
    size         = each.value.disk_size
    ssd          = true
    interface    = "scsi0"
    file_format  = "raw"
    discard      = "on"
    cache        = "none"
  }
  cdrom {
    file_id   = var.talos.iso
    interface = "ide2"
  }
  network_device {
    bridge      = "vmbr0"
    mac_address = each.value.mac_addr
    firewall    = false
    model       = "virtio"
  }
}

resource "proxmox_virtual_environment_vm" "workers" {
  for_each      = var.workers
  name          = each.value.name
  description   = "kubernetes worker"
  tags          = ["kubernetes", "worker"]
  node_name     = "proxmox"
  vm_id         = each.value.vm_id
  on_boot       = false
  boot_order    = ["scsi0", "ide2"]
  tablet_device = false
  bios          = "seabios"

  operating_system {
    type = "l26"
  }
  agent {
    enabled = true
  }
  cpu {
    cores = each.value.cores
    type  = "host"
  }
  memory {
    dedicated = each.value.memory
    floating  = each.value.memory
  }
  disk {
    datastore_id = "local-zfs"
    backup       = false
    size         = each.value.disk_size
    ssd          = true
    interface    = "scsi0"
    file_format  = "raw"
    discard      = "on"
    cache        = "none"
  }
  cdrom {
    file_id   = var.talos.iso
    interface = "ide2"
  }
  network_device {
    bridge      = "vmbr0"
    mac_address = each.value.mac_addr
    firewall    = false
    model       = "virtio"
  }
}
