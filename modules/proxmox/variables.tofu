variable "talos" {
  type = object({
    version = string
    iso     = string
    image   = string
  })
}

variable "controlplanes" {
  type = map(object({
    name      = string
    vm_id     = number
    memory    = number
    cores     = number
    disk_size = number
    mac_addr  = string
    ip_addr   = string
  }))
}

variable "workers" {
  type = map(object({
    name      = string
    vm_id     = number
    memory    = number
    cores     = number
    disk_size = number
    mac_addr  = string
    ip_addr   = string
  }))
}
