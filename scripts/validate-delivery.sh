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
  rendered_dir="$(mktemp -d)"
  trap 'rm -rf "$rendered_dir"' EXIT
  helm template timnormark-com "$ROOT_DIR/deploy/helm/timnormark-com" -f "$ROOT_DIR/deploy/helm/timnormark-com/values-staging.yaml" >"$rendered_dir/staging.yaml"
  helm template timnormark-com "$ROOT_DIR/deploy/helm/timnormark-com" -f "$ROOT_DIR/deploy/helm/timnormark-com/values-prod.yaml" >"$rendered_dir/prod.yaml"
  if grep -q '^kind: Ingress$' "$rendered_dir"/*.yaml; then
    echo "unexpected Kubernetes Ingress rendered; app routing must use Gateway API" >&2
    exit 1
  fi
  grep -q '^kind: Gateway$' "$rendered_dir/staging.yaml"
  grep -q '^kind: HTTPRoute$' "$rendered_dir/staging.yaml"
  grep -q '^kind: Gateway$' "$rendered_dir/prod.yaml"
  grep -q '^kind: HTTPRoute$' "$rendered_dir/prod.yaml"
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
