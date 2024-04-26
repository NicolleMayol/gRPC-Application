output "eks_cluster_id" {
  description = "ID of the created EKS cluster"
  value       = module.eks_cluster.cluster_id
}

output "eks_worker_node_instance_role_arn" {
  description = "ARN of the IAM role for EKS worker nodes"
  value       = module.eks_workers.worker_node_instance_role_arn
}

output "codebuild_project_name" {
  description = "Name of the CodeBuild project for CI/CD"
  value       = aws_codebuild_project.eks_ci_cd.name
}
