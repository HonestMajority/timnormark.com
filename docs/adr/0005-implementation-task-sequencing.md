# ADR 0005: Implementation Task Sequencing

## Status

Accepted

## Context

The target architecture has several moving parts. Building them in the wrong order would create infrastructure before there is an artifact to deploy, or deployment automation before there is a stable environment shape.

## Decision

Sequence implementation in small, reviewable tasks:

1. Add a minimal Rust web app that serves the public site shell using plain HTML, CSS, and JavaScript.
2. Add local development and test commands for the app.
3. Add a production container image build.
4. Add GitHub Actions pull request checks.
5. Add the AWS/Terraform foundation for EKS and required shared resources.
6. Add Helm packaging for the app, including Gateway API routing.
7. Add Argo CD staging reconciliation.
8. Add Argo CD Image Updater Git write-back for staging image digests.
9. Add manual GitHub Actions production promotion that commits the staging digest to production config.
10. Add production Argo CD reconciliation.
11. Add Vault or an equivalent secret-management path once there are real runtime secrets to manage.

Each task should leave the repo in a working state and avoid committing placeholder secrets or nonfunctional infrastructure stubs.

## Consequences

- Early pull requests stay small and easy to review.
- The app exists before the platform tries to deploy it.
- CI and deployment automation can be validated against real artifacts instead of empty scaffolding.
- Secret-management work is deferred until there is a concrete secret boundary to implement.

## Boundaries

- Do not scaffold application, Terraform, Helm, or Argo CD code just to make directories exist.
- Do not introduce production promotion before staging digest tracking exists.
- Do not add Vault before the app has real runtime secret requirements.
