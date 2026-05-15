variable "aws_region" {
  description = "AWS region that hosts the EKS cluster."
  type        = string
}

variable "environment" {
  description = "Deployment environment name, for example staging or prod."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "repository_name" {
  description = "ECR repository name for the application image."
  type        = string
  default     = "timnormark-com"
}

variable "vpc_cidr" {
  description = "CIDR block for the EKS VPC."
  type        = string
  default     = "10.40.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to use for public and private subnets."
  type        = list(string)
  default     = []
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "EC2 instance types for the default managed node group."
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_desired_size" {
  description = "Desired node count for the default managed node group."
  type        = number
  default     = 1
}

variable "node_min_size" {
  description = "Minimum node count for the default managed node group."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum node count for the default managed node group."
  type        = number
  default     = 3
}
