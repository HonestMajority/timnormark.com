# Architecture and Process

This directory records the initial technical direction for timnormark.com. The docs are intentionally practical: they define the target shape and the order of work without scaffolding application or infrastructure code.

## ADRs

- [ADR 0001: Kubernetes-first AWS architecture](adr/0001-kubernetes-first-aws-architecture.md)
- [ADR 0002: GitOps deployment and promotion flow](adr/0002-gitops-deployment-and-promotion-flow.md)
- [ADR 0003: Public repository policy](adr/0003-public-repository-policy.md)
- [ADR 0004: Environment model](adr/0004-environment-model.md)
- [ADR 0005: Implementation task sequencing](adr/0005-implementation-task-sequencing.md)

## Current Direction

- Application: one Rust web app serving plain HTML, CSS, and JavaScript.
- Platform: AWS EKS managed with Terraform, packaged with Helm, and reconciled by Argo CD.
- Routing: Kubernetes Gateway API with Envoy Gateway for v1 app traffic.
- Delivery: GitHub Actions for checks, image builds, and manual production promotion.
- Secrets: no secrets, state, kubeconfigs, real API keys, Vault unseal keys, or production data in Git.
