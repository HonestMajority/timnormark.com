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
- `deploy/helm/timnormark-com/` owns Kubernetes app manifests.
- `deploy/helm/timnormark-com/values-staging.yaml` and `values-prod.yaml` define environment namespaces, hosts, and image digests.
- `deploy/argocd/` owns Argo CD Applications. Image Updater is configured only for staging.
- `.github/workflows/pr-checks.yaml` runs static delivery validation on pull requests.
- `.github/workflows/build-main.yaml` publishes `ghcr.io/honestmajority/timnormark.com` from `apps/web/Dockerfile` after merges to `main`.
- `.github/workflows/promote-prod.yaml` updates the prod Helm digest through a manual promotion pull request.

## Open Source Policy

This repository is public by design. Do not commit secrets, Terraform state, kubeconfigs, real API keys, Vault keys, or production data.

## Documentation

- [Architecture and process docs](docs/README.md)
