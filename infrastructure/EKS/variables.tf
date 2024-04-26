variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

variable "instance_type"{
  description = "Type of instance"
  type = string
}

variable "codecommit_repo_name"{
  description = "Repository name"
  type = string
}


 variable "pipeline_bucket_name" {
  description = "Name of the bucket"
  type = string
 }      
 
 variable "pipeline_bucket_prefix"{
  description = "prefix for the bucket name"
  type = string
 }   
 
 variable "codebuild_project_name"{
  description = "Name of the project"
  type = string
 }


 variable "codebuild_role"{
  description = "Name of the role"
  type = string
 }       
 
 variable "codepipeline_name" {
  description = "Name of the pipeline"
  type = string
 }

variable "vpc_id" {
  description = "ID of the VPC"
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID of the security group"
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Set to true to enable cluster creator admin permissions"
  type        = bool
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags"
  type        = map(string)
}

variable "codecommit_repo_url" {
  description = "URL of the CodeCommit repository"
}

variable "app_ingress_name" {
  description = "Name for the application ingress"
  type        = string
}