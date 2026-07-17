# Task runner for timnormark.com. Requires `just` and the docker CLI with a
# running Docker daemon.

# Prefer the `docker compose` plugin; fall back to the standalone binary.
compose := `docker compose version >/dev/null 2>&1 && echo "docker compose" || echo "docker-compose"`

# List available recipes
default:
    @just --list

# --- Temporary static prod lane (Cloudflare Tunnel) ---------------------------
# Serves site/ with stock nginx:alpine as compose project
# `timnormark-static-prod`, published on localhost:17310 by default (override
# with TIMNORMARK_STATIC_PROD_PORT). The local cloudflared tunnel points
# timnormark.com at this port while the long-term AWS/EKS lane is built out.
# See the "Temporary Static Production Lane" section in README.md.

static_prod_compose := compose + " -f ops/static-prod/docker-compose.yml"

# Start nginx serving site/ and wait until healthy
run-static-prod:
    {{ static_prod_compose }} up --detach --wait
    @echo "Static prod: http://localhost:${TIMNORMARK_STATIC_PROD_PORT:-17310}"

# Stop the static prod stack
static-prod-down:
    {{ static_prod_compose }} down --remove-orphans
