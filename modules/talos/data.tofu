data "talos_machine_configuration" "controlplanes" {
  cluster_name       = var.controlplanes.controlplane1.cluster_name
  machine_type       = "controlplane"
  cluster_endpoint   = "https://${var.controlplanes.controlplane1.ip_addr}:6443"
  machine_secrets    = talos_machine_secrets.machine_secrets.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  examples           = false
  docs               = false
  config_patches = [
    yamlencode(local.common_machine_config)
  ]
}

data "talos_machine_configuration" "workers" {
  cluster_name       = var.controlplanes.controlplane1.cluster_name
  machine_type       = "worker"
  cluster_endpoint   = "https://${var.controlplanes.controlplane1.ip_addr}:6443"
  machine_secrets    = talos_machine_secrets.machine_secrets.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  examples           = false
  docs               = false
}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.controlplanes.controlplane1.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [var.controlplanes.controlplane1.ip_addr]
  nodes = [
    for ip in local.nodes : ip.ip_addr
  ]
}

data "http" "kubernetes_health" {
  url      = "https://${var.controlplanes.controlplane1.ip_addr}:6443/healthz"
  method   = "GET"
  insecure = true
  # open PR: https://github.com/hashicorp/terraform-provider-http/pull/211
  # ca_cert_pem = base64decode(talos_machine_secrets.machine_secrets.client_configuration.ca_certificate)
  # client_cert_pem = base64decode(talos_machine_secrets.machine_secrets.client_configuration.client_certificate)
  # client_key_pem  = base64decode(talos_machine_secrets.machine_secrets.client_configuration.client_key)
  request_headers = {
    Accept = "application/json"
  }
  retry {
    attempts = 10
  }
  lifecycle {
    postcondition {
      condition     = contains([200, 401], self.status_code)
      error_message = "status code invalid"
    }
  }
}
