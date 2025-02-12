terraform {
  required_providers {
    talos = {
      source = "siderolabs/talos"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    flux = {
      source = "fluxcd/flux"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}
