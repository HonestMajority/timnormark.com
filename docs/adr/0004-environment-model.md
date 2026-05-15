# ADR 0004: Environment Model

## Status

Accepted

## Context

The project needs a simple environment model that supports local development, automatic staging deploys, and controlled production promotion. The model should keep public repository contents safe while leaving enough configuration in Git for reviewable operations.

## Decision

Use three environment classes:

| Environment | Purpose | Deployment path | Data policy |
| --- | --- | --- | --- |
| Local | Developer iteration | Run locally without EKS where practical | Local-only test data |
| Staging | Main-branch validation | Automatic GitOps reconciliation after merge to `main` | Non-production data only |
| Production | Public site and real personal tools | Manual promotion of the staging image digest | Production data never committed |

Environment-specific deployment config should be declarative and reviewable in Git when it is non-sensitive. Sensitive values should be referenced by name and resolved at runtime from the chosen secret system.

## Consequences

- Local development should be fast and should not depend on cloud credentials for ordinary app work.
- Staging is the proving ground for the exact image that can later be promoted to production.
- Production config changes are explicit Git changes, not hidden cluster edits.
- Vault can be introduced later without changing the high-level environment model.

## Boundaries

- Staging and production should not share databases, secrets, or mutable runtime state.
- Production promotion should use an already-built digest from staging.
- Any future preview environments should be documented as a separate decision before implementation.
