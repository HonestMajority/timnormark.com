#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 0 ]]; then
  echo "usage: $0" >&2
  exit 2
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAGING_VALUES_FILE="$ROOT_DIR/deploy/helm/timnormark-com/values-staging.yaml"
PROD_VALUES_FILE="$ROOT_DIR/deploy/helm/timnormark-com/values-prod.yaml"

DIGEST="$(python3 - "$STAGING_VALUES_FILE" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()
image_block = re.search(r"(?ms)^image:\n(?P<body>(?:^  .*\n?)+)", text)
if not image_block:
    raise SystemExit("could not find image block in values-staging.yaml")
digest_match = re.search(r'(?m)^  digest:\s*"?([^"\n#]*)"?\s*(?:#.*)?$', image_block.group("body"))
if not digest_match:
    raise SystemExit("could not find image.digest in values-staging.yaml")
print(digest_match.group(1).strip())
PY
)"

if [[ ! "$DIGEST" =~ ^sha256:[a-f0-9]{64}$ ]]; then
  echo "staging image.digest must look like sha256:<64 lowercase hex chars>" >&2
  exit 2
fi

python3 - "$PROD_VALUES_FILE" "$DIGEST" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
digest = sys.argv[2]
text = path.read_text()
updated = re.sub(r'(^image:\n(?:^  .*\n?)*?^  digest:\s*).*$',
                 rf'\1"{digest}"',
                 text,
                 count=1,
                 flags=re.MULTILINE)
if updated == text:
    raise SystemExit("could not find image.digest in values-prod.yaml")
path.write_text(updated)
PY

if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "PROMOTED_DIGEST=$DIGEST" >> "$GITHUB_ENV"
fi

echo "Updated deploy/helm/timnormark-com/values-prod.yaml to staging digest $DIGEST"
