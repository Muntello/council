#!/usr/bin/env python3
"""
Update ~/.claude/plugins/installed_plugins.json to point at the new
plugin version after deploy.sh has synced the cache directory.

Usage: python3 scripts/bump-registry.py
"""
import json, subprocess, datetime, pathlib, sys

ROOT = pathlib.Path(__file__).parent.parent
REGISTRY = pathlib.Path.home() / ".claude/plugins/installed_plugins.json"

version = json.loads((ROOT / ".claude-plugin/plugin.json").read_text())["version"]
sha = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT).decode().strip()
install_path = str(pathlib.Path.home() / f".claude/plugins/cache/council/council/{version}")

if not pathlib.Path(install_path).exists():
    print(f"✗ Cache directory not found: {install_path}")
    print(f"  Run ./scripts/deploy.sh first.")
    sys.exit(1)

data = json.loads(REGISTRY.read_text())
entry = data["plugins"]["council@council"][0]

old_version = entry["version"]
entry["installPath"] = install_path
entry["version"] = version
entry["lastUpdated"] = datetime.datetime.now(datetime.UTC).strftime("%Y-%m-%dT%H:%M:%S.000Z")
entry["gitCommitSha"] = sha

REGISTRY.write_text(json.dumps(data, indent=4))

print(f"Updated council@council: {old_version} → {version}")
print(f"  installPath: {install_path}")
print(f"  gitCommitSha: {sha[:16]}...")
print(f"\nRestart Claude Code to activate v{version}.")
