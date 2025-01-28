terraform {
  required_providers {
    talos = {
      source = "siderolabs/talos"
    }
    helm = {
      source = "hashicorp/helm"
    }
    flux = {
      source = "fluxcd/flux"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}
