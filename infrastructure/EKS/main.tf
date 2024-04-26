# EKS Cluster Module
module "eks_cluster" {
  source            = "terraform-aws-modules/eks/aws"
  version           = "~> 20.0"

  cluster_name      = var.cluster_name
  cluster_version   = var.cluster_version
  vpc_id            = var.vpc_id
  subnet_ids        = var.subnet_ids

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

  enable_irsa = true # Enable IAM roles for service accounts
}

# CI/CD Pipeline
resource "aws_codepipeline" "eks_ci_cd" {
  name     = var.codepipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = var.codecommit_repo_name
        BranchName     = var.codecommit_repo_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.eks_ci_cd.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "CodeDeployToEKS"
      input_artifacts  = ["build_output"]
      version          = "1"

      configuration = {
        ApplicationName = var.application_name
        EksClusterName  = module.eks_cluster.cluster_id
      }
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = var.codepipeline_role
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "codepipeline.amazonaws.com"
      },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_iam_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
}

# ALB Ingress Controller Module
module "app_ingress" {
  source            = "terraform-aws-modules/alb/aws"
  version           = "5.14.0"

  name              = "simetrik-test-ingress"
  load_balancer_type = "application"

  security_groups   = [var.security_group_id]
  subnets           = var.subnet_ids

  tags = {
    Environment = "Production"
    Project     = "Simetrik"
  }

  # Configure listener and target group for gRPC
  listeners = {
    grpc = {
      port     = 50051
      protocol = "HTTP2"
      default_action = {
        type             = "forward"
        target_group_key = "grpc_target_group"
      }
    }
  }

  target_groups = {
    grpc_target_group = {
      name_prefix   = "grpc"
      port          = 50051
      protocol      = "HTTP"
      health_check  = {
        enabled             = true
        path                = "/healthz"
        port                = "traffic-port"
        protocol            = "HTTP2"
        matcher             = "200-399"
      }
      target_type   = "ip"
      deregistration_delay = 30
    }
  }
}
