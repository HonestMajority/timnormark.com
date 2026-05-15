#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if command -v terraform >/dev/null 2>&1; then
  terraform -chdir="$ROOT_DIR/infra/terraform" fmt -check -recursive
  terraform -chdir="$ROOT_DIR/infra/terraform" init -backend=false
  terraform -chdir="$ROOT_DIR/infra/terraform" validate
else
  echo "terraform not found; skipping terraform fmt/validate"
fi

if command -v helm >/dev/null 2>&1; then
  helm lint "$ROOT_DIR/deploy/helm/timnormark-com" -f "$ROOT_DIR/deploy/helm/timnormark-com/values-staging.yaml"
  helm lint "$ROOT_DIR/deploy/helm/timnormark-com" -f "$ROOT_DIR/deploy/helm/timnormark-com/values-prod.yaml"
  helm template timnormark-com "$ROOT_DIR/deploy/helm/timnormark-com" -f "$ROOT_DIR/deploy/helm/timnormark-com/values-staging.yaml" >/dev/null
  helm template timnormark-com "$ROOT_DIR/deploy/helm/timnormark-com" -f "$ROOT_DIR/deploy/helm/timnormark-com/values-prod.yaml" >/dev/null
else
  echo "helm not found; skipping helm lint/template"
fi

if command -v ruby >/dev/null 2>&1; then
  ruby -e 'require "yaml"; ARGV.each { |path| YAML.load_file(path) }' \
    "$ROOT_DIR"/deploy/argocd/*.yaml \
    "$ROOT_DIR"/.github/workflows/*.yaml \
    "$ROOT_DIR"/deploy/helm/timnormark-com/values*.yaml
else
  echo "ruby not found; skipping YAML syntax check"
fi
