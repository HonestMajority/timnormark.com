#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 sha256:<digest>" >&2
  exit 2
fi

DIGEST="$1"

if [[ ! "$DIGEST" =~ ^sha256:[a-f0-9]{64}$ ]]; then
  echo "digest must look like sha256:<64 lowercase hex chars>" >&2
  exit 2
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALUES_FILE="$ROOT_DIR/deploy/helm/timnormark-com/values-prod.yaml"

python3 - "$VALUES_FILE" "$DIGEST" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
digest = sys.argv[2]
text = path.read_text()
updated = re.sub(r'(^  digest: ).*$', rf'\1"{digest}"', text, count=1, flags=re.MULTILINE)
if updated == text:
    raise SystemExit("could not find image.digest in values-prod.yaml")
path.write_text(updated)
PY

echo "Updated deploy/helm/timnormark-com/values-prod.yaml to $DIGEST"
