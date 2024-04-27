
module "eks_cluster" {
  source            = "terraform-aws-modules/eks/aws"
  version           = "~> 20.0"

  cluster_name      = var.cluster_name
  cluster_version   = var.cluster_version
  vpc_id            = var.vpc_id
  subnet_ids        = var.public_subnet_ids

  cluster_endpoint_public_access = true

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = [var.instance_type]
  }

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 1
      instance_types = [var.instance_type]
    }
  }

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}


module "app_ingress" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"
  subnets = var.public_subnet_ids
  vpc_id = var.vpc_id

  security_groups = [var.security_group_id]
  http_tcp_listeners = [
    {
      port               = 50051
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
  target_groups = [
    {
      name_prefix      = "grpc-"
      backend_protocol = "HTTP"
      backend_port     = 50051
      target_type      = "ip"
    }
  ]
}


################################# CI/ CD #######################

resource "aws_s3_bucket" "pipeline_bucket" {
  bucket_prefix = var.pipeline_bucket_prefix
  acl           = "private"

  tags = {
    Name = var.pipeline_bucket_name
  }
}

resource "aws_codebuild_project" "eks_ci_cd" {
  name          = var.codebuild_project_name
  description   = "CI/CD for EKS deployment"
  service_role  = aws_iam_role.codebuild_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type        = "BUILD_GENERAL1_SMALL"
    image               = "aws/codebuild/standard:4.0"
    type                = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    environment_variable {
      name  = "S3_BUCKET"
      value = aws_s3_bucket.pipeline_bucket.bucket
    }
    environment_variable {
      name  = "ECR_REPOSITORY_URI"
      value = var.aws_ecr_repository
    }
  }
  source {
    type            = "CODECOMMIT"
    location        = var.codecommit_repo_url
    buildspec       = "buildspec.yml"
    report_build_status = true
  }

}

resource "aws_iam_role" "codebuild_role" {
  name                  = var.codebuild_role
  assume_role_policy    = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action   = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name                  = "codebuild-policy-attachment"
  policy_arn            = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
  roles                 = [aws_iam_role.codebuild_role.name]
}
