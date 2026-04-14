---
name: council
description: Convene a council of expert AI personas to analyze any question in parallel. Usage: council <question> | council --auto on|off | council --tech <question>
user_invocable: true
---

# Council Skill

You are orchestrating a consultation council. Follow every step exactly and in order.

## Step 1: Parse the request

The user's input arrives as the skill arguments. Parse it:

**If input contains `--auto on`:**
→ Save to memory: key `council_auto_mode`, value `true`
→ Reply: "Council auto-mode enabled. I'll offer a technical council before entering Plan Mode."
→ Stop here, do not proceed further.

**If input contains `--auto off`:**
→ Save to memory: key `council_auto_mode`, value `false`
→ Reply: "Council auto-mode disabled."
→ Stop here, do not proceed further.

**If input contains `--tech`:**
→ Set MODE = TECHNICAL
→ Set QUESTION = everything after `--tech` in the input
→ If QUESTION is empty after `--tech`, ask the user: "What technical aspect would you like the council to analyze?"
→ Stop here until they respond.

**Otherwise:**
→ Set MODE = UNIVERSAL
→ Set QUESTION = the full input

If QUESTION is empty after parsing, ask the user: "What would you like the council to analyze?"

## Step 2: Load personas

Use the Read tool to read the persona file. To find the plugin root: use the Glob tool to find `personas/universal.json` matching pattern `**/personas/universal.json` within the current working directory, or construct the path by taking the directory of this skill file and going up two levels (from `skills/council/SKILL.md` → up to `skills/` → up to plugin root). The personas files are at `personas/universal.json` and `personas/technical.json` within that root.

- If MODE = UNIVERSAL → read `personas/universal.json`
- If MODE = TECHNICAL → read `personas/technical.json`

Parse the JSON content to get the array of persona objects. Each has: `id`, `name`, `role`, `prompt` (and `topics` for universal personas).

## Step 3: Select experts

**If MODE = TECHNICAL:** Use all 6 personas from `technical.json`. No selection needed.

**If MODE = UNIVERSAL:** Select 4–6 personas from the 12 in `universal.json`:
- Match QUESTION keywords against each persona's `topics` array
- Prioritize personas whose topics overlap with the question domain
- Ensure diversity: no more than 2 personas sharing the same primary topic
- When uncertain, always include Feynman (clarity) and Taleb (risk) as anchors
- Minimum 4, maximum 6 selected

## Step 4: Launch parallel agents

**CRITICAL: All expert Agent() calls MUST be launched in a single message as simultaneous parallel tool calls. Do not launch them one by one.**

**How to ensure parallelism:** First, build the COMPLETE list of all agent prompts (one per selected persona). Then, in a SINGLE response, emit all Agent() tool calls simultaneously — do not call the Agent tool one at a time in a loop.

For each selected persona, construct this prompt:

```
You are {persona.name}, {persona.role}.

{persona.prompt}

The user seeks your perspective on:
"{QUESTION}"

Respond in character. Be specific, opinionated, and direct.
Keep your response to 150–250 words.
Do not use any tools. Just give your perspective as {persona.name}.
```

Use the Agent tool for each expert with:
- `description`: `"Council expert: {persona.name}"`
- `subagent_type`: `"general-purpose"`
- `prompt`: the filled template above

**Launch all agents simultaneously. Wait for all to complete before proceeding.**

## Step 5: Synthesize and present

After all agents return their responses, output the Council Report in this exact format:

```markdown
## Council Report

**Topic:** {one-line summary of QUESTION}
**Experts convened:** {comma-separated list of persona names}

---

### Voices

**{Expert 1 Name}** *({role})*
{their response — preserve their voice, trim only if over 300 words}

**{Expert 2 Name}** *({role})*
{their response}

[repeat for all experts]

---

### Points of Disagreement

{2–3 specific tensions between experts. Name the experts. Be concrete about what they disagree on.}

### Synthesis

{3–5 sentences integrating the key insights. Do not merely summarize — find what holds across perspectives and what the tensions reveal.}

### Recommendation

{1–2 actionable sentences. Be direct. Name a specific choice if possible.}
```
