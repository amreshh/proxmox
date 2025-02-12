output "kubeconfig" {
  value     = talos_cluster_kubeconfig.kubeconfig
  sensitive = true
}
