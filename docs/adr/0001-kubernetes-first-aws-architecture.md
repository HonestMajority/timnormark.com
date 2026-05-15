# ADR 0001: Kubernetes-first AWS Architecture

## Status

Accepted

## Context

timnormark.com is both a personal branding site and a future home for private/personal tools. The project should be a useful learning platform for production-style operations without becoming a large multi-service system before there is application demand.

## Decision

Use a Kubernetes-first architecture on AWS:

- One Rust web application to start.
- Plain HTML, CSS, and JavaScript served by the Rust app.
- AWS EKS for Kubernetes.
- Terraform for AWS infrastructure.
- Helm for Kubernetes application packaging.
- Argo CD for GitOps reconciliation.
- GitHub Actions for pull request checks, image builds, and production promotion.

The initial repo remains a monorepo. Application code, infrastructure code, Helm charts, and deployment config can live side by side when those parts are introduced, but this decision does not require scaffolding them immediately.

## Consequences

- The platform is more operationally complex than a static host or single VM.
- The repo should keep environment config explicit and reviewable because Git becomes the operational source of truth.
- Early implementation should be incremental: a minimal app first, then container build, then infrastructure, then GitOps.
- Local development should not require a full EKS cluster.

## Boundaries

- Do not introduce extra services until the Rust app needs them.
- Prefer boring platform defaults over custom controllers or bespoke deployment automation.
- Keep all cloud credentials, Terraform state, kubeconfigs, and real secrets outside the public repository.
