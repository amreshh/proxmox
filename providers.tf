terraform {
  required_version = "~>1.12"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.112.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.9.5"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.6.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.9.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = "https://${local.env.controlplanes.controlplane1.ip_addr}:6443"
    cluster_ca_certificate = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.ca_certificate)
    client_certificate     = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.client_key)
  }
}

provider "kubernetes" {
  host                   = "https://${local.env.controlplanes.controlplane1.ip_addr}:6443"
  cluster_ca_certificate = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.ca_certificate)
  client_certificate     = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.client_certificate)
  client_key             = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.client_key)
}

provider "kubectl" {
  host                   = "https://${local.env.controlplanes.controlplane1.ip_addr}:6443"
  cluster_ca_certificate = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.ca_certificate)
  client_certificate     = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.client_certificate)
  client_key             = base64decode(module.talos.kubeconfig.kubernetes_client_configuration.client_key)
  load_config_file       = false
}

provider "flux" {
  kubernetes = {
    host                   = "https://${local.env.controlplanes.controlplane1.ip_addr}:6443"
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
