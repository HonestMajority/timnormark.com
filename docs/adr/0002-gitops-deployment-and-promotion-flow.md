# ADR 0002: GitOps Deployment and Promotion Flow

## Status

Accepted

## Context

The project should use a clear deployment model where pull requests are safe, merges deploy staging automatically, and production promotion is deliberate. Deployed versions should be traceable back to Git and immutable image digests.

## Decision

Use this deployment flow:

1. Pull requests run checks only.
2. Merges to `main` build and publish a container image.
3. Argo CD Image Updater detects the new `main` image and writes the selected image digest back to Git for staging.
4. Argo CD reconciles staging from the Git config it owns.
5. Production is promoted by a manual GitHub Action.
6. The production action promotes the exact image digest already running in staging by committing production config back to Git.
7. Argo CD reconciles production from that committed config.

Git is the source of truth for deployed versions. Runtime-only changes in the cluster should be treated as drift and reconciled away.

## Consequences

- Staging can move automatically after merge while production remains an explicit operator action.
- Production deploys are digest-based, not tag-based, so the promoted artifact is the artifact already observed in staging.
- Argo CD Image Updater needs Git write-back credentials with minimal repo permissions.
- Rollbacks should be ordinary Git reverts or promotion commits that point at a previous known-good digest.

## Boundaries

- Pull requests must not deploy to shared environments by default.
- Production promotion must not rebuild the image.
- Avoid manual `kubectl apply` as a normal release path.
