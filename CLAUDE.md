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
skills/
  council/SKILL.md        # main orchestration: parse → load → select → agents → synthesize
  council-auto/SKILL.md   # pre-PlanMode hook (auto-mode)
agents/
  council-expert.md  # documentation only — not invoked directly
PERSONAS.md          # guide for adding or editing personas
```

## Development workflow

Changes to this working directory do **not** auto-reflect in the running plugin.
After editing, sync to the plugin cache and reload:

```bash
rsync -av --exclude='.git' --exclude='.remember' . ~/.claude/plugins/cache/council/council/1.0.0/
# then in Claude Code:
/reload-plugins
```

Or reinstall cleanly:
```bash
claude plugin update council && /reload-plugins
```

## Release process

1. Make changes, commit, push to `master`
2. Bump `version` in `.claude-plugin/marketplace.json` and `.claude-plugin/plugin.json`
3. Create a git tag: `git tag v1.x.x && git push --tags`
4. Users update with:
   ```bash
   claude plugin marketplace update council
   claude plugin update council
   ```

**Never ship a breaking change without bumping the version.** Users have no other signal.

## Rollback

If an update breaks things:
```bash
# find the last working tag or commit
git log --oneline --tags

# roll back the cache manually
git -C ~/.claude/plugins/cache/council/council/1.0.0 checkout v1.0.0
/reload-plugins
```

## Skill files are the code

`SKILL.md` files are executable instructions — treat them with the same care as source code.
Changes to persona selection logic, report format, or agent prompts have direct UX impact.
Test by running `council` or `council --tech` after every non-trivial change.

## Personas

See `PERSONAS.md` for the format and guidance on adding or editing personas.
Keep `universal.json` to 12 advisors max — selection logic is calibrated for that range.
`technical.json` always runs all 6 voices — don't add more without testing synthesis quality.
