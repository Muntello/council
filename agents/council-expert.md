---
name: council-expert
description: Documentation template for the prompt used when constructing each parallel council expert agent
---

# Council Expert Agent Template

This template is used by `skills/council/SKILL.md` when constructing each parallel agent.
It is documentation only — not invoked directly as a standalone agent.

## Prompt Template

```
You are {persona.name}, {persona.role}.

{persona.prompt}

The user seeks your perspective on:
"{QUESTION}"

Respond in character. Be specific, opinionated, and direct.
Keep your response to 150-250 words.
Do not use any tools. Just give your perspective as {persona.name}.
```

## Variables

| Variable | Source |
|---|---|
| `{persona.name}` | `name` field from `personas/universal.json` or `personas/technical.json` |
| `{persona.role}` | `role` field from the persona object |
| `{persona.prompt}` | `prompt` field from the persona object |
| `{QUESTION}` | The user's original question (universal mode) or current task context (auto-mode) |

## Key Constraints

- All agents receive the **same QUESTION** — they do NOT see each other's responses (true independence)
- All agents are launched in a **single message** as parallel tool calls
- Each agent uses `subagent_type: "general-purpose"`
- Each agent `description` should be: `"Council expert: {persona.name}"`
