# Networking Module
module "networking" {
  source                   = "./networking"
  vpc_cidr_block           = "10.0.0.0/16"
  public_subnet_cidr_block = "10.0.1.0/24"
  private_subnet_cidr_block = "10.0.2.0/24"
}

# EKS Module
module "eks" {
  source            = "./eks"
  cluster_name      = "my-cluster"
  cluster_version   = "1.21"
  instance_type     = "t3.medium"
  desired_capacity  = 2
  codecommit_repo_name      = "simetrik-test"
  pipeline_bucket_name      = "eks-pipeline-artifacts"
  pipeline_bucket_prefix    = "eks-pipeline-artifacts-"
  codebuild_project_name    = "eks-ci-cd"
  codebuild_role_name       = "codebuild-role"
  codepipeline_name         = "eks-pipeline"
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "ID of the created public subnet"
  value       = module.networking.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of the created private subnet"
  value       = module.networking.private_subnet_id
}

output "eks_cluster_id" {
  description = "ID of the created EKS cluster"
  value       = module.eks.eks_cluster_id
}

output "eks_worker_node_instance_role_arn" {
  description = "ARN of the IAM role for EKS worker nodes"
  value       = module.eks.eks_worker_node_instance_role_arn
}

output "codebuild_project_name" {
  description = "Name of the CodeBuild project for CI/CD"
  value       = module.eks.codebuild_project_name
}
