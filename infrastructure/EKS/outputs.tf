output "eks_cluster_id" {
  description = "ID of the created EKS cluster"
  value       = module.eks_cluster.cluster_id
}
