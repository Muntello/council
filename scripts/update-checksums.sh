#!/usr/bin/env bash
# Regenerate personas/checksums.json after editing persona files.
# Run this before committing changes to universal.json or technical.json.

set -euo pipefail
cd "$(dirname "$0")/.."

VERSION=$(python3 -c "import json,sys; print(json.load(open('.claude-plugin/plugin.json'))['version'])")

hash_file() {
  local file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
  else
    shasum -a 256 "$file" | awk '{print $1}'
  fi
}

UNIVERSAL_HASH=$(hash_file "personas/universal.json")
TECHNICAL_HASH=$(hash_file "personas/technical.json")

cat > personas/checksums.json <<EOF
{
  "version": "$VERSION",
  "algorithm": "sha256",
  "files": {
    "personas/universal.json": "$UNIVERSAL_HASH",
    "personas/technical.json": "$TECHNICAL_HASH"
  }
}
EOF

echo "Updated personas/checksums.json for v$VERSION"
echo "  universal.json  ${UNIVERSAL_HASH:0:16}..."
echo "  technical.json  ${TECHNICAL_HASH:0:16}..."
