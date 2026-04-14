# Council — Claude Code Plugin

Assemble a council of expert AI personas to analyze any question or decision. Each expert runs as an independent parallel agent for true diversity of perspective.

## Installation

Council is a plugin — it is **not built into Claude Code** and must be installed manually.

```bash
git clone https://github.com/Muntello/council ~/.claude/plugins/council
```

No API keys required. Uses your current Claude Code session.

After installation, restart Claude Code. The `council` skill will appear in your available skills list.

## Usage

Invoke council by asking Claude to run the skill, or typing in the prompt:

```
council Should I use PostgreSQL or MongoDB for this project?
```

### Technical council (all 6 technical voices)
```
council --tech The new auth middleware design
```

### Auto-mode: offer council before every plan
```
council --auto on    # enable
council --auto off   # disable
```

When auto-mode is on, Claude will ask "Run technical council before planning? [y/N]" before entering Plan Mode.

> **Note:** If Claude says "Unknown skill: council", the plugin is not installed or Claude Code was not restarted after installation.

## Updating

**If installed from GitHub** — pull the latest and reinstall:

```bash
cd /path/to/council && git pull
claude plugin install --local .
```

**If installed locally during development** — reinstall from source:

```bash
claude plugin install --local /path/to/council
```

Restart Claude Code after updating.

## How it works

1. Claude selects the most relevant expert personas for your question
2. All experts run **simultaneously** as independent parallel agents
3. Each expert responds in character without seeing others' answers
4. Claude synthesizes into a structured Council Report with Voices, Disagreements, Synthesis, and Recommendation

## Universal Advisors

12 personas available — Claude selects 4–6 per query based on topic relevance:

| Persona | Role | Best for |
|---|---|---|
| Richard Feynman | Physicist & Teacher | Clarity, first principles |
| Nassim Taleb | Risk Theorist | Risk, antifragility, uncertainty |
| DHH | Pragmatic Developer | Software simplicity, YAGNI |
| Hannah Arendt | Political Theorist | Ethics, collective impact |
| Friedrich Nietzsche | Philosopher | Values, creativity |
| Carl Sagan | Astronomer & Skeptic | Science, long-term thinking |
| Rick Rubin | Music Producer | Essence, removing the unnecessary |
| Diogenes | Cynic Philosopher | Radical honesty, simplicity |
| Eliezer Yudkowsky | AI Safety Researcher | AI risk, second-order effects |
| Christopher Alexander | Architect & Pattern Theorist | Systems design, patterns |
| Tim Urban | Writer & Thinker | Mental models, time scales |
| Adam Savage | Maker & Experimenter | Iteration, prototyping |

## Technical Voices

All 6 run in parallel for `--tech` and auto-mode:

| Voice | Focus |
|---|---|
| Security Skeptic | Threat vectors, attack surface |
| AppSec Engineer | OWASP, secure implementation |
| Performance Engineer | Bottlenecks, scalability |
| Pragmatic Architect | Complexity vs value, technical debt |
| User Advocate | UX, real-user perspective |
| Operations Voice | Deploy, monitoring, failure modes |

## Customizing personas

See [PERSONAS.md](PERSONAS.md) to add your own experts.

## License

MIT
