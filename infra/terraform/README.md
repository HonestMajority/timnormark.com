# Terraform AWS substrate

This directory owns the AWS substrate for timnormark.com. The app manifests live
under `deploy/`, and Terraform should not manage Kubernetes workload objects.

The scaffold is intentionally parameterized and does not include account IDs,
real tfvars, kubeconfigs, state, or credentials.

## Intended responsibilities

- ECR repository for the application image.
- VPC networking for EKS.
- EKS control plane and managed node groups.
- IAM roles needed by cluster add-ons and delivery automation.
- Optional DNS and certificate substrate when the AWS account details are known.
- GitHub Actions OIDC IAM role permissions for ECR push when CI/CD ownership is
  known.
- EKS node or IRSA permissions for Kubernetes image pulls from ECR.

## Bootstrap notes

Create local or environment-specific tfvars outside Git, for example:

```hcl
aws_region     = "eu-north-1"
cluster_name   = "timnormark-com-staging"
environment    = "staging"
repository_name = "timnormark-com"
```

Then run:

```sh
terraform init
terraform fmt -check -recursive
terraform validate
```

State backend configuration is deliberately left local in this scaffold. Add an
S3/DynamoDB backend once the AWS account and state ownership model are decided.
