talos = {
  version      = "1.13.4"
  iso          = "local:iso/talos_1.13.4_qemu.iso"
  image        = "factory.talos.dev/metal-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.13.4"
  vm_disk      = "/dev/vda"
  cluster_name = "dev"
  time_servers = ["192.168.20.1"]
  dns_servers  = ["192.168.122.1/32"]
}

kubernetes_version = "1.36.1"
kubernetes_extra_manifests = [
  "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.5.1/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml",
  "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.5.1/config/crd/standard/gateway.networking.k8s.io_gateways.yaml",
  "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.5.1/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml",
  "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.5.1/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml",
  "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.5.1/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml",
  "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.5.1/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml"
]

cilium_version = "1.19.4"

flux_version = {
  version      = "2.18.4"
  sync_version = "1.14.6"
}

controlplanes = {
  controlplane1 = {
    name      = "k8s-controlplane-1"
    vm_id     = 101
    memory    = 8192 # MiB
    cores     = 2
    disk_size = 50 # GiB
    mac_addr  = "52:54:00:62:d5:d2"
    ip_addr   = "192.168.122.52"
  }
}

workers = {
  worker1 = {
    name      = "k8s-worker-1"
    vm_id     = 102
    memory    = 16384 # MiB
    cores     = 4
    disk_size = 100 # GiB
    mac_addr  = "52:54:00:04:51:28"
    ip_addr   = "192.168.122.251"
  }
}
