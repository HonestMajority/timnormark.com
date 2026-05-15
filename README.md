# timnormark.com

Personal website and learning platform for Tim Normark.

## Goals

- Public landing page for developer consulting and personal branding.
- Home for small personal web applications and calculators.
- Practical learning project for Kubernetes, Terraform, AWS, Helm, Argo CD, Vault, and CI/CD.

## Initial Architecture

- One monorepo.
- One Rust web application to start.
- Plain HTML, CSS, and JavaScript for the frontend.
- Kubernetes-first deployment model on AWS EKS.
- Terraform for AWS infrastructure.
- Helm for Kubernetes application packaging.
- Argo CD for GitOps delivery.
- GitHub Actions for CI, image build, and production promotion.
- Gateway API app routing through Envoy Gateway.

## Deployment Model

- Pull requests run checks only.
- Merge to `main` builds and publishes an image.
- Argo CD Image Updater promotes new `main` images into staging by writing back to Git.
- Production is promoted manually from the exact image digest already running in staging.
- Git is the source of truth for deployed versions.

## Local Development

Run the web application locally:

```sh
cargo run -p timnormark-web
```

The server listens on `http://localhost:3000` by default. Set `PORT` to use a
different port.

Useful checks:

```sh
cargo fmt --check
cargo test
cargo check
```

Current routes:

- `/` landing page
- `/tools` tools index
- `/assets/*` static assets
- `/api` API index
- `/api/status` JSON status
- `/health` health check

## Delivery Scaffold

- `infra/terraform/` owns the AWS substrate scaffold, including ECR, VPC, and EKS.
- `deploy/helm/timnormark-com/` owns Kubernetes app manifests, including the
  app `Deployment`, `Service`, `Gateway`, and `HTTPRoute`.
- `deploy/helm/timnormark-com/values-staging.yaml` and `values-prod.yaml` define environment namespaces, hosts, and image digests.
- `deploy/argocd/` owns Argo CD Applications. Image Updater is configured only for staging.
- `.github/workflows/pr-checks.yaml` runs static delivery validation on pull requests.
- `.github/workflows/build-main.yaml` publishes the ECR image from the root `Dockerfile` after merges to `main`.
- `.github/workflows/promote-prod.yaml` copies the staging Helm digest into prod through a manual promotion pull request.

The v1 delivery path assumes one AWS ECR repository, represented in scaffold
files as `123456789012.dkr.ecr.eu-north-1.amazonaws.com/timnormark-com`.
Replace the placeholder AWS account, region, and repository name when the live
AWS account is known. GitHub Actions must have an OIDC-backed IAM role in the
`AWS_GITHUB_ACTIONS_ECR_PUSH_ROLE_ARN` repository variable, plus `AWS_REGION`
and `ECR_REPOSITORY` variables, before it can push to ECR. EKS nodes or pod
IRSA configuration must be allowed to pull from the repository before the Helm
release can run in-cluster. Argo CD Image Updater also needs ECR registry auth
for the same account and region before staging digest write-back can work.

Kubernetes app routing is modeled with Gateway API resources rendered by the
Helm chart. The cluster must have Gateway API CRDs and Envoy Gateway installed,
with an `envoy-gateway` `GatewayClass` available before Argo CD can reconcile the
application routes. AWS remains substrate for EKS, DNS, certificates, and any
load balancer integration exposed by the Envoy Gateway installation.

## Open Source Policy

This repository is public by design. Do not commit secrets, Terraform state, kubeconfigs, real API keys, Vault keys, or production data.

## Documentation

- [Architecture and process docs](docs/README.md)
