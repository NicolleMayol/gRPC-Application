variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

variable "instance_type" {
  description = "Instance type for worker nodes"
  type        = string
}

variable "desired_capacity" {
  description = "Desired capacity for worker nodes"
  type        = number
}

variable "codecommit_repo_name" {
  description = "Name of the CodeCommit repository"
  type        = string
}

variable "pipeline_bucket_name" {
  description = "Name of the S3 bucket for CodePipeline artifacts"
  type        = string
}

variable "pipeline_bucket_prefix" {
  description = "Prefix for the S3 bucket for CodePipeline artifacts"
  type        = string
}

variable "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  type        = string
}

variable "codebuild_role_name" {
  description = "Name of the IAM role for CodeBuild"
  type        = string
}

variable "codepipeline_name" {
  description = "Name of the CodePipeline"
  type        = string
}
