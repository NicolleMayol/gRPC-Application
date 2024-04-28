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
module "eks" {
  source            = "./eks"
  cluster_name      = "simetrik-cluster"
  cluster_version   = "1.23"
  instance_type     = "t3.medium"
  codecommit_repo_name      = "simetrik-test"
  pipeline_bucket_name      = "eks-pipeline-artifacts"
  pipeline_bucket_prefix    = "eks-pipeline-artifacts-"
  codebuild_project_name    = "eks-ci-cd"
  codebuild_role       = "codebuild-role"
  codepipeline_name         = "eks-pipeline"
  app_ingress_name = "grpc-ingress"
  
  vpc_id          = module.networking.vpc_id
  subnet_ids      = concat(module.networking.public_subnet_ids, module.networking.private_subnet_ids) // Concatenating both lists
  public_subnet_ids = module.networking.public_subnet_ids // Assigning the public subnet IDs directly
  security_group_id = module.networking.security_group_id
  enable_cluster_creator_admin_permissions = true
  tags = {
    Environment = "production"
    Team        = "devops"
  }

  aws_ecr_repository = aws_ecr_repository.app_repository.repository_url
  codecommit_repo_url = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/simetrik-test"  ## UPDATE WITH YOUR CODE COMMIT REPOSITORY
}

resource "aws_ecr_repository" "app_repository" {
  name = "simetrik-ecr-repository"
}