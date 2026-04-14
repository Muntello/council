---
name: council-auto
description: Auto-mode hook for council plugin — check if technical council should run before entering Plan Mode
user_invocable: false
---

# Council Auto-Mode

This skill implements the pre-planning council check for auto-mode.

## When to use this skill

Check memory for key `council_auto_mode` **before invoking EnterPlanMode**.

- If `council_auto_mode` is `true` → follow the steps below
- If `council_auto_mode` is `false` or not set → proceed with EnterPlanMode immediately, do not interrupt

## Steps when auto-mode is active

**Step 1: Ask the user**

Before entering Plan Mode, ask:
> "**Technical council available** — run expert review before planning? [y/N]"

Wait for the user's response.

**Step 2: If user confirms (y, yes, Y)**

- Use the current task or question as the QUESTION for the council
- Load all 6 personas from `personas/technical.json` (find the plugin root using Glob on `**/personas/technical.json`)
- Launch all 6 technical voices as parallel Agent() calls in a SINGLE message (same parallel constraint as the main council skill)
- Use this agent prompt for each persona:

```
You are {persona.name}, {persona.role}.

{persona.prompt}

The team is about to plan the following:
"{QUESTION}"

Give your technical perspective on what could go wrong, what to watch out for, or what the plan should prioritize. Be specific and direct. 150–200 words.
```

- Present the full Council Report (Voices + Points of Disagreement + Synthesis + Recommendation)
- Then proceed with EnterPlanMode

**Step 3: If user declines (n, no, N, or empty)**

Proceed with EnterPlanMode immediately. No council.

## Memory key reference

| Key | Values | Set by |
|---|---|---|
| `council_auto_mode` | `true` / `false` | `council` skill via `--auto on\|off` |
