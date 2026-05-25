talos = {
  version      = "1.13.2"
  iso          = "local:iso/talos_1.13.2.iso"
  image        = "factory.talos.dev/metal-installer/376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba:v1.13.2"
  vm_disk      = "/dev/vda"
  cluster_name = "dev"
  time_servers = ["192.168.20.1"]
  dns_servers  = ["192.168.122.1/32"]
}

kubernetes_version = "1.36.0"
kubernetes_extra_manifests = [
  "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.5.1/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml",
  "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.5.1/config/crd/standard/gateway.networking.k8s.io_gateways.yaml",
  "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.5.1/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml",
  "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.5.1/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml",
  "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.5.1/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml",
  "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.5.1/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml"
]

cilium_version = "1.19.3"

flux_version = {
  version      = "2.18.3"
  sync_version = "1.14.5"
}

controlplanes = {
  controlplane1 = {
    name      = "k8s-controlplane-1"
    vm_id     = 101
    memory    = 8192 # MiB
    cores     = 2
    disk_size = 10 # GiB
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
