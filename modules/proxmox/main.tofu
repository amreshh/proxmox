resource "proxmox_vm_qemu" "controlplanes" {
  for_each    = var.controlplanes
  name        = each.value.name
  target_node = "proxmox"
  vmid        = each.value.vmid
  desc        = "kubernetes controlplane"
  bios        = "seabios"
  onboot      = "false"
  memory      = each.value.memory
  balloon     = 0
  cores       = each.value.cores
  sockets     = 1
  vcpus       = 0
  scsihw      = "virtio-scsi-single"
  agent       = 1
  boot        = "order=scsi0;ide2;net0"
  skip_ipv6   = true
  tags        = "kubernetes,controlplane"

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/talos_1.9.1.iso"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          asyncio    = "io_uring"
          backup     = false
          cache      = "none"
          discard    = "false"
          emulatessd = true
          size       = "${each.value.disk_size}G"
          storage    = "local-zfs"
          replicate  = false
        }
      }
    }
  }
  network {
    id       = 0
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
    macaddr  = each.value.mac_addr
  }
}

resource "proxmox_vm_qemu" "workers" {
  for_each    = var.workers
  name        = each.value.name
  target_node = "proxmox"
  vmid        = each.value.vmid
  desc        = "kubernetes worker"
  bios        = "seabios"
  onboot      = "false"
  memory      = each.value.memory
  balloon     = 0
  cores       = each.value.cores
  sockets     = 1
  vcpus       = 0
  scsihw      = "virtio-scsi-single"
  agent       = 1
  boot        = "order=scsi0;ide2;net0"
  skip_ipv6   = true
  tags        = "kubernetes,worker"

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/talos_1.9.1.iso"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          asyncio    = "io_uring"
          backup     = false
          cache      = "none"
          discard    = "false"
          emulatessd = true
          size       = "${each.value.disk_size}G"
          storage    = "local-zfs"
          replicate  = false
        }
      }
    }
  }
  network {
    id       = 0
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
    macaddr  = each.value.mac_addr
  }
}
