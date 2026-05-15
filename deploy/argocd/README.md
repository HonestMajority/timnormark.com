# Argo CD delivery

These manifests define the desired GitOps shape for staging and prod.

- `application-staging.yaml` syncs the staging Helm values.
- `application-prod.yaml` syncs the prod Helm values.
- Argo CD Image Updater is enabled only on staging.
- Staging tracks the mutable `main` image tag with the Image Updater `digest`
  strategy. Its Helm annotations intentionally write the resolved
  `sha256:...` value into `image.digest`, while `image.tag` remains the mutable
  tag to inspect.
- Prod receives the exact staging image digest through the manual GitHub
  promotion workflow.

Replace placeholder repo URLs, Argo CD project names, destination servers, and
hostnames when the live cluster setup is known.

Image Updater is pointed at the placeholder ECR repository
`123456789012.dkr.ecr.eu-north-1.amazonaws.com/timnormark-com`. Replace the AWS
account ID, region, and repository name once Terraform has created the live ECR
repository. The Image Updater installation must be configured with registry auth
for ECR in that AWS account and region, and the cluster must be able to pull the
same image through node IAM or IRSA.
