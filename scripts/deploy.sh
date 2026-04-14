#!/usr/bin/env bash
# Deploy council plugin to Claude Code cache.
# Reads version from plugin.json — no manual path editing needed.
#
# Usage:
#   ./scripts/deploy.sh           — deploy current working tree
#   ./scripts/deploy.sh --verify  — verify deployed cache after deploy

set -euo pipefail
cd "$(dirname "$0")/.."

VERSION=$(python3 -c "import json,sys; print(json.load(open('.claude-plugin/plugin.json'))['version'])")
CACHE_DIR="$HOME/.claude/plugins/cache/council/council/$VERSION"

echo "Deploying council v$VERSION → $CACHE_DIR"

# Regenerate checksums before deploy so the cache gets the fresh manifest
./scripts/update-checksums.sh

mkdir -p "$CACHE_DIR"
rsync -av \
  --exclude='.git' \
  --exclude='.remember' \
  --exclude='.claude' \
  --exclude='node_modules' \
  . "$CACHE_DIR/"

echo ""

# Auto-update the plugin registry if the version changed.
REGISTRY="$HOME/.claude/plugins/installed_plugins.json"
if [[ -f "$REGISTRY" ]]; then
  REGISTERED_VERSION=$(python3 -c "
import json, pathlib
data = json.loads(pathlib.Path('$REGISTRY').read_text())
entry = data['plugins'].get('council@council', [{}])[0]
print(entry.get('version', ''))
" 2>/dev/null || echo "")
  if [[ "$REGISTERED_VERSION" != "$VERSION" ]]; then
    echo "Version changed ($REGISTERED_VERSION → $VERSION) — updating plugin registry..."
    python3 scripts/bump-registry.py
    echo "⚠ Restart Claude Code to activate v$VERSION (not just /reload-plugins)."
  else
    echo "Done. Run /reload-plugins in Claude Code to activate."
  fi
else
  echo "Done. Run /reload-plugins in Claude Code to activate."
fi
echo ""

if [[ "${1:-}" == "--verify" ]]; then
  echo "Post-deploy integrity check:"
  hash_file() {
    local file="$1"
    if command -v sha256sum >/dev/null 2>&1; then
      sha256sum "$file" | awk '{print $1}'
    else
      shasum -a 256 "$file" | awk '{print $1}'
    fi
  }

  FAIL=0
  while IFS= read -r line; do
    rel=$(echo "$line" | python3 -c "import sys,json; d=json.load(sys.stdin); [print(k,v) for k,v in d['files'].items()]" 2>/dev/null) || continue
    # parse via python for robustness
    true
  done < /dev/null

  python3 - "$CACHE_DIR" <<'PYEOF'
import json, sys, hashlib, pathlib

cache_dir = pathlib.Path(sys.argv[1])
manifest_path = cache_dir / "personas" / "checksums.json"

if not manifest_path.exists():
    print("  ⚠ checksums.json not found in cache")
    sys.exit(1)

manifest = json.loads(manifest_path.read_text())
fail = False

for rel_path, expected in manifest["files"].items():
    full = cache_dir / rel_path
    if not full.exists():
        print(f"  ✗ {rel_path}  FILE NOT FOUND")
        fail = True
        continue
    actual = hashlib.sha256(full.read_bytes()).hexdigest()
    if actual == expected:
        print(f"  ✓ {rel_path}  {actual[:16]}...")
    else:
        print(f"  ✗ {rel_path}")
        print(f"    expected: {expected}")
        print(f"    got:      {actual}")
        fail = True

if fail:
    print("\n⚠ Integrity check FAILED")
    sys.exit(1)
else:
    print(f"\nAll checks passed — council v{manifest['version']} deployed cleanly.")
PYEOF
fi
