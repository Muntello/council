#!/usr/bin/env bash
# Regenerate personas/checksums.json after editing persona files,
# then update the pinned manifest hash in skills/council/SKILL.md.
# Run this before committing changes to universal.json or technical.json.
# deploy.sh calls this automatically.

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

# Pin the new manifest hash inside SKILL.md so it has an independent trust anchor.
MANIFEST_HASH=$(hash_file "personas/checksums.json")
SKILL_FILE="skills/council/SKILL.md"

python3 - "$SKILL_FILE" "$MANIFEST_HASH" <<'PYEOF'
import sys, re

skill_path, new_hash = sys.argv[1], sys.argv[2]
content = open(skill_path).read()
pattern = r'(`sha256:)[a-f0-9]{64}(`)'
if not re.search(pattern, content):
    print("  warning: pinned hash pattern not found in SKILL.md — update manually", file=sys.stderr)
    sys.exit(1)
updated = re.sub(pattern, rf'\g<1>{new_hash}\g<2>', content)
open(skill_path, 'w').write(updated)
PYEOF

echo "Updated personas/checksums.json for v$VERSION"
echo "  universal.json  ${UNIVERSAL_HASH:0:16}..."
echo "  technical.json  ${TECHNICAL_HASH:0:16}..."
echo "  manifest hash   ${MANIFEST_HASH:0:16}...  → pinned in SKILL.md"
