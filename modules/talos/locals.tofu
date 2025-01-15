locals {
  nodes = concat(var.controlplane_ips, var.worker_ips)
  common_machine_config = {
    machine = {
      certSANs = [
        for ip in local.nodes : ip
      ]
    }
    cluster = {
      network = {
        cni = {
          name = "none"
        }
      }
      proxy = {
        disabled = true
      }
    }
  }
}
