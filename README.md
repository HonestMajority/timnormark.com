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

## Open Source Policy

This repository is public by design. Do not commit secrets, Terraform state, kubeconfigs, real API keys, Vault keys, or production data.

## Documentation

- [Architecture and process docs](docs/README.md)
