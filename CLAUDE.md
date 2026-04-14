# Council Plugin — Development Guide

## What this is

A Claude Code plugin that assembles AI expert personas to analyze questions in parallel.
Core mechanic: skill reads persona JSON → launches parallel Agent() calls → synthesizes into a structured report.

## File structure

```
.claude-plugin/
  plugin.json        # plugin identity
  marketplace.json   # enables: claude plugin marketplace add Muntello/council
personas/
  universal.json     # 12 universal advisors (Claude selects 4–6 per query)
  technical.json     # 6 technical voices (all run in --tech and auto-mode)
  checksums.json     # SHA-256 manifest — regenerate with scripts/update-checksums.sh
scripts/
  deploy.sh            # deploy to plugin cache (reads version from plugin.json automatically)
  update-checksums.sh  # regenerate checksums.json after editing persona files
  bump-registry.py     # update installed_plugins.json after a version bump (required before restart)
skills/
  council/SKILL.md        # main orchestration: parse → load → verify → select → agents → synthesize
  council-auto/SKILL.md   # pre-PlanMode hook (auto-mode)
agents/
  council-expert.md  # documentation only — not invoked directly
PERSONAS.md          # guide for adding or editing personas
```

## Development workflow

Changes to this working directory do **not** auto-reflect in the running plugin.

### Patch changes (no version bump)

Content-only edits (SKILL.md, persona files, agent prompts):

```bash
./scripts/deploy.sh --verify
# then in Claude Code:
/reload-plugins
```

`/reload-plugins` is sufficient — the version path stays the same, CC just re-reads the files.

### Version bump

When bumping the version number, `/reload-plugins` is **not enough** — CC must be restarted:

```bash
# 1. Bump version in .claude-plugin/plugin.json and .claude-plugin/marketplace.json
# 2. Commit and push
./scripts/deploy.sh --verify        # sync cache, update checksums + pinned hash
python3 scripts/bump-registry.py    # update installed_plugins.json to new path
# 3. Fully restart Claude Code (not just /reload-plugins)
```

If you edited persona files, checksums are regenerated automatically by `deploy.sh`.

## Release process

1. Make changes, commit, push to `master`
2. Bump `version` in `.claude-plugin/marketplace.json` **and** `.claude-plugin/plugin.json`
   - The report template in SKILL.md reads version from `checksums.json` automatically — no manual edit needed there
3. Run `./scripts/deploy.sh` — this regenerates `checksums.json` with the new version, updates the pinned hash in SKILL.md, and syncs the cache
4. Update the plugin registry to point at the new version path:
   ```bash
   python3 scripts/bump-registry.py
   ```
   (or edit `~/.claude/plugins/installed_plugins.json` manually: update `installPath`, `version`, `gitCommitSha` for `council@council`)
5. **Fully restart Claude Code** — `/reload-plugins` alone does NOT switch versions; it only reloads content from the already-registered path
6. Create a git tag and push: `git tag v1.x.x && git push --tags`
7. Users update with:
   ```bash
   claude plugin update council@council
   ```
   (the `@council` marketplace suffix is required — `claude plugin update council` fails)

**Never ship a breaking change without bumping the version.** Users have no other signal.

After each release, verify:
- [ ] `council --verify` shows the new version number
- [ ] `council --tech <simple question>` produces a full report with the correct version in the header
- [ ] Auto-mode hook fires correctly before Plan Mode (test after any Claude Code update — this is the only framework coupling point that breaks silently)

## Rollback

If an update breaks things:
```bash
# find the last working tag
git log --oneline --tags

# check out the old tag into the working directory
git checkout v1.x.x

# redeploy and update registry
./scripts/deploy.sh
python3 scripts/bump-registry.py

# restart Claude Code
```

## Skill files are the code

`SKILL.md` files are executable instructions — treat them with the same care as source code.
Changes to persona selection logic, report format, or agent prompts have direct UX impact.
Test by running `council` or `council --tech` after every non-trivial change.

## Threat model

This plugin runs in a personal, single-user Claude Code environment. The threat model reflects that.

**Trusted:** skill files (SKILL.md), persona JSON files, the Claude Code runtime itself.

**Untrusted:** user input passed via `council <question>`. It is wrapped in `<question>` XML tags before being injected into agent prompts. Do not remove this wrapping.

**Blast radius if persona files are compromised** (e.g. via a malicious process writing to the plugin cache):
An attacker controls the system prompt injected into all parallel subagents. They could redirect agent output or attempt to use tools if the "no tools" constraint is bypassed.

**Mitigations in place:** XML wrapping of user input, explicit "Do not use any tools" constraint per agent, named partial failure reporting, SHA-256 integrity check on persona files at load time (`council --verify` to check manually).

**Not mitigated (by design, single-user scope):** cryptographic verification of plugin artifacts (the checksums.json itself is not signed). Revisit if this plugin is ever deployed in a multi-user or shared environment — at that point, sign the manifest with a key not stored in the cache.

## Personas

See `PERSONAS.md` for the format and guidance on adding or editing personas.
Keep `universal.json` to 12 advisors max — selection logic is calibrated for that range.
`technical.json` always runs all 6 voices — don't add more without testing synthesis quality.
