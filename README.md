# Council — Claude Code Plugin

Assemble a council of expert AI personas to analyze any question or decision. Each expert runs as an independent parallel agent for true diversity of perspective.

## Installation

Council is a plugin — it is **not built into Claude Code** and must be installed manually.

```bash
claude plugin marketplace add Muntello/council
claude plugin install council@Muntello/council
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

```bash
claude plugin marketplace update Muntello/council
claude plugin update council@Muntello/council
```

Restart Claude Code after updating.

## Example

Running `council --tech` on this very repository:

```
council --tech analyze the technical solution of the council plugin itself
```

**Output:**

> Launching 6 experts in parallel: Security Skeptic, AppSec Engineer, Performance Engineer, Pragmatic Architect, User Advocate, Operations Voice...

---

## Council Report

**Topic:** Technical solution of the Council Claude Code plugin
**Experts convened:** Security Skeptic, AppSec Engineer, Performance Engineer, Pragmatic Architect, User Advocate, Operations Voice

---

### Voices

**Security Skeptic** *(Threat Modeler)*
Prompt injection is the primary attack surface. The `<question>` XML wrapping is advisory, not enforced. Supply chain is the installation threat — the plugin installs from GitHub with no pinned commit hash, no checksum, no signature. Persona files are trusted implicitly: `prompt` fields are injected into agent instructions without sanitization. Prioritize: pin installs to a specific commit SHA, validate persona JSON against a schema before injection.

**Performance Engineer** *(Performance & Scalability)*
Six simultaneous Agent() calls with no per-agent timeout. If one agent hangs, the entire synthesis step waits indefinitely. Persona selection (4–6 by topic matching) is implemented ad hoc by the LLM at runtime — non-deterministic and untestable. **Priority fix:** add per-agent timeout and define explicit behavior on partial failure — synthesize from whoever responded within N seconds.

**Pragmatic Architect** *(Systems Architect)*
The pre-PlanMode hook is the riskiest seam — if Anthropic changes Agent() behavior, auto-mode breaks silently. The persona selection logic lives inside LLM instructions and is not auditable. Parallel auto-mode calls accumulate cost with no circuit breaker. Good call on JSON as pure data. Bad call on the unauditable selection criterion.

**Operations Voice** *(SRE / DevOps)*
The synthesis step has no defined behavior when an agent times out — the orchestrator will improvise silently. Observability is zero. The update path is a manual footgun: `git pull` with no version pin ships breaking changes to all users immediately. Priority: (1) named fallback for failed agents, (2) session-level success indicator, (3) pin installs to a git tag.

---

### Points of Disagreement

- **Security Skeptic vs Pragmatic Architect** — structural isolation of user input (technical barriers) vs. managing internal complexity first. Both valid depending on whether this is a public or personal tool.
- **User Advocate vs Operations Voice** — User Advocate wants auto-mode default changed to `Y` for more engagement; Operations Voice wants a circuit breaker for fewer surprise invocations. Direct contradiction.

### Synthesis

The architecture is clean — JSON as pure data, skills as logic, parallelism via Agent() — but three systemic gaps need attention. First: no partial-failure handling means the entire synthesis hangs on a single slow agent. Second: supply chain trust without verification — persona files are injected as trusted content with no integrity check. Third: the persona selection criterion exists only inside a prompt, making it untestable and non-deterministic.

### Recommendation

Add explicit fallback in the skill: when an agent fails, name it in the report — do not synthesize from silence. Pin the installation to a git tag instead of HEAD for safe rollback.

---

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
