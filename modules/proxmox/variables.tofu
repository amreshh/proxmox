variable "controlplanes" {
  type = map(object({
    name      = string
    vmid      = number
    memory    = number
    cores     = number
    disk_size = number
    mac_addr  = string
  }))
}

variable "workers" {
  type = map(object({
    name      = string
    vmid      = number
    memory    = number
    cores     = number
    disk_size = number
    mac_addr  = string
  }))
}
