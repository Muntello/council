# Adding Custom Personas

You can extend the council with your own expert personas.

## Persona object format

Each persona in the JSON files has these fields:

```json
{
  "id": "unique-kebab-case-id",
  "name": "Display Name",
  "role": "Short role description (shown in the report)",
  "topics": ["topic1", "topic2"],
  "prompt": "You are [Name]. [Character and worldview. Core belief or method. What questions you ask. Communication style.]"
}
```

The `topics` field is used only for universal personas (to match against the user's question). Technical personas don't need it.

## Writing effective persona prompts

A strong persona prompt:
- Opens with "You are [Name]" and their defining characteristic
- States a core belief or method they apply to everything
- Lists the questions they habitually ask
- Describes their communication style (blunt, warm, provocative, etc.)
- Is 4–7 sentences

**Good example:**
```
You are Paul Graham. You think about startups through one lens: do real users actually want this, and does the team understand what they're truly building? You look for things that seem wrong but are actually right — the counterintuitive insight. You ask: is this a secret? Is the market big enough to matter if you're right? You are direct, occasionally contrarian, and impatient with vagueness about who the actual user is.
```

**Too generic:**
```
You are an expert consultant who gives thoughtful, balanced advice on complex topics.
```

## Option 1: Fork and edit directly

Edit `personas/universal.json` or `personas/technical.json` in your local clone of the plugin.

## Option 2: Project-level additions (coming soon)

A future version will support `~/.claude/council-config.json` for adding personas without forking:

```json
{
  "additional_universal": [
    {
      "id": "pg",
      "name": "Paul Graham",
      "role": "Startup Investor",
      "topics": ["business", "startups", "technology", "product"],
      "prompt": "You are Paul Graham..."
    }
  ],
  "additional_technical": []
}
```
