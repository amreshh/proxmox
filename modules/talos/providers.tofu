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
    http = {
      source = "hashicorp/http"
    }
  }
}
