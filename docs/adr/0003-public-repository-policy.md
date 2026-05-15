# ADR 0003: Public Repository Policy

## Status

Accepted

## Context

The repository is public. It may eventually contain application code, Terraform, Helm charts, Argo CD configuration, documentation, and CI workflows. Public infrastructure code is acceptable, but operational secrets and private data are not.

## Decision

Keep this repository open-source friendly and safe to publish:

- Commit source code, docs, tests, Helm templates, non-sensitive Terraform, and declarative environment config.
- Do not commit secrets, Terraform state, kubeconfigs, real API keys, private tokens, Vault unseal keys, production data, or private personal data.
- Use placeholders and documented variable names for required external values.
- Store secret values in the appropriate external system, such as GitHub Actions secrets initially and Vault when introduced.
- Keep generated artifacts out of Git unless they are intentionally reviewed source artifacts.

## Consequences

- Infrastructure modules must separate public definitions from private values.
- Documentation should show shapes and examples without exposing real identifiers when those identifiers are sensitive.
- CI should include checks that make accidental secret commits less likely.
- Any future private tooling must treat user data and production data as runtime data, not repository content.

## Boundaries

- Do not commit real `.tfstate` files or backend state snapshots.
- Do not commit kubeconfigs for staging or production clusters.
- Do not commit real `.env` files.
- Do not use the public repo as a database or backup location.
