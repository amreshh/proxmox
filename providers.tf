terraform {
  required_version = "~>1.10"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.104.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.10.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.1.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.8.6"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.8.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = "https://${var.controlplanes.controlplane1.ip_addr}:6443"
    cluster_ca_certificate = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.ca_certificate)
    client_certificate     = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.client_key)
  }
}

provider "kubernetes" {
  host                   = "https://${var.controlplanes.controlplane1.ip_addr}:6443"
  cluster_ca_certificate = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.ca_certificate)
  client_certificate     = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.client_certificate)
  client_key             = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.client_key)
}

provider "flux" {
  kubernetes = {
    host                   = "https://${var.controlplanes.controlplane1.ip_addr}:6443"
    cluster_ca_certificate = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.ca_certificate)
    client_certificate     = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.client_key)
  }
  git = {
    url = "https://github.com/amreshh/proxmox.git"
    http = {
      username = "git"
      password = var.github_token
    }
  }
}
