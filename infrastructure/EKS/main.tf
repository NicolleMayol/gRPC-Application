# Provision EKS Cluster
module "eks_cluster" {
  source            = "terraform-aws-modules/eks/aws"
  cluster_name      = var.cluster_name
  cluster_version   = var.cluster_version
  subnets           = [module.networking.private_subnet_id]
  # Other configuration options can be added here
}

# Set up worker nodes
module "eks_workers" {
  source            = "terraform-aws-modules/eks/aws//modules/workers"
  cluster_name      = module.eks_cluster.cluster_id
  instance_type     = var.instance_type
  desired_capacity  = var.desired_capacity
  # Other configuration options can be added here
}

# Create Application Load Balancer (ALB) for Ingress
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [module.networking.public_subnet_id]
  enable_http2       = true # Enable HTTP/2 support
}

resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443 # HTTPS port for ALB
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # ALB SSL policy supporting HTTP/2

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

resource "aws_lb_target_group" "app_target_group" {
  name     = "app-tg"
  port     = 50051 # gRPC server port
  protocol = "HTTP"
  vpc_id   = module.networking.vpc_id
}

# Create CodeCommit Repository
resource "aws_codecommit_repository" "app_repo" {
  repository_name = var.codecommit_repo_name
}

# Create S3 bucket for CodePipeline artifact store
resource "aws_s3_bucket" "pipeline_bucket" {
  bucket_prefix = var.pipeline_bucket_prefix
  acl           = "private"

  tags = {
    Name = var.pipeline_bucket_name
  }
}

# CI/CD with CodeBuild
resource "aws_codebuild_project" "eks_ci_cd" {
  name          = var.codebuild_project_name
  description   = "CI/CD for EKS deployment"
  service_role  = aws_iam_role.codebuild_role.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
  }
  source {
    type            = "CODECOMMIT"
    location        = aws_codecommit_repository.app_repo.clone_url_http
    buildspec       = "buildspec.yml" # Assuming you have a buildspec file in your CodeCommit repository
    report_build_status = true
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = var.codebuild_role_name
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
  roles      = [aws_iam_role.codebuild_role.name]
}

# Create CodePipeline
resource "aws_codepipeline" "eks_pipeline" {
  name     = var.codepipeline_name
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name            = "SourceAction"
      category        = "Source"
      owner           = "AWS"
      provider        = "CodeCommit"
      version         = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName             = aws_codecommit_repository.app_repo.name
        BranchName                 = "master"
        PollForSourceChanges       = "true"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "BuildAction"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = aws_codebuild_project.eks_ci_cd.name
      }
    }
  }
}
