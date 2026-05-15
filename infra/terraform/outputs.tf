output "ecr_repository_url" {
  description = "Application image repository URL."
  value       = aws_ecr_repository.app.repository_url
}

output "cluster_name" {
  description = "EKS cluster name reserved for this environment."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API endpoint."
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "VPC ID used by the EKS cluster."
  value       = module.vpc.vpc_id
}
