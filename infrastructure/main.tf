terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "simetrik-test"
}

# Networking Module
module "networking" {
  source = "./networking"
  
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
  codecommit_repo_name      = "simetrik-test"
  pipeline_bucket_name      = "eks-pipeline-artifacts"
  pipeline_bucket_prefix    = "eks-pipeline-artifacts-"
  codebuild_project_name    = "eks-ci-cd"
  codebuild_role       = "codebuild-role"
  codepipeline_name         = "eks-pipeline"

  vpc_id          = module.networking.vpc_id
  subnet_ids      = [module.networking.public_subnet_id, module.networking.private_subnet_id]
  control_plane_subnet_ids = [module.networking.public_subnet_id] 
  security_group_id = module.networking.security_group_id
  enable_cluster_creator_admin_permissions = true
  tags = {
    Environment = "production"
    Team        = "devops"
  }

  codecommit_repo_url = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/simetrik-test"
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
