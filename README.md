# Conductor

> Deterministic-first AI orchestration. 156+ specialist roles, 21 workflow skills, 85+ validation plugins — one brain that routes, monitors, and hands off between them.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Code of Conduct](https://img.shields.io/badge/code%20of%20conduct-enforced-blue.svg)](CODE_OF_CONDUCT.md)

Conductor is a markdown-first orchestration layer that sits on top of three proven open-source libraries and adds deterministic routing, cost control, governance gates, and cross-role session state. It works inside your IDE — no server, no compiled binary, no runtime dependencies beyond your AI coding agent.

You describe what you want. Conductor figures out which specialist(s) should do it, how much it should cost, whether it needs a governance gate, and how to hand context from one role to the next — then watches the work, catches scope drift, and persists state so nothing gets lost between sessions.

---

## Standing on the Shoulders of Giants

Conductor exists because three open-source projects already solved the hard problems. We didn't rebuild what they built — we built the routing layer that connects them.

### [The Agency](https://github.com/msitarzewski/agency-agents) — by Mike Sitarzewski

156 meticulously crafted AI agent role definitions across 13 domains — engineering, design, marketing, product, testing, sales, project management, support, paid media, spatial computing, game development, academic, and strategy. Each agent has a defined personality, communication style, core workflows, technical deliverables, and success metrics. Born from a Reddit thread and months of iteration, The Agency provides the talent pool that Conductor routes to.

**What Conductor uses it for:** Every specialist role in the system — from Backend Architect to Whimsy Injector — is a real file from this library. The registry indexes all 156 roles with capability fingerprints so the routing algorithm can find the right agent in milliseconds. Conductor never invents roles; it only activates what exists here.

> MIT License · © 2025 AgentLand Contributors

### [gstack](https://github.com/garrytan/gstack) — by Garry Tan

An open-source software factory that turns AI coding agents into a virtual engineering team you actually manage. Created by Y Combinator's CEO — who used it to write 600,000+ lines of production code in 60 days — gstack provides 21 workflow skills and 12 binary tools as slash commands: `/office-hours` for product framing, `/plan-ceo-review` for strategic review, `/review` for code review, `/qa` for browser-based testing, `/ship` for release engineering, `/investigate` for debugging, and more. All markdown, all MIT, all designed for Claude Code and compatible agents.

**What Conductor uses it for:** Workflow execution patterns. When the conductor routes a task to "review mode," it's gstack's `/review` skill that structures the code review. When QA is needed, gstack's `/qa` skill opens a real browser. Conductor reads these patterns but never modifies them — `proactive=false` is enforced at activation to prevent gstack's scope-expansion behavior from overriding Conductor's routing policy.

> MIT License · © 2026 Garry Tan

### [Promptfoo](https://github.com/promptfoo/promptfoo) — by the Promptfoo team

The industry-standard CLI and library for evaluating and red-teaming LLM applications. 85+ validation plugins, 50+ assertion types, 90+ model providers. Battle-tested in production serving 10M+ users. Runs 100% locally — prompts never leave your machine. Now part of OpenAI (March 2026), and still open source under MIT.

**What Conductor uses it for:** Quality gates. Every task completion runs through promptfoo assertions matched to your profile — structure checks, cost assertions, latency bounds, LLM-rubric scoring, factuality checks, and (at production-strict) full red-team plugin suites including injection testing, authorization checks, and data leakage detection. The optimizer runs checks cheapest-first: regex/structure → latency → llm-rubric → g-eval → red-team.

> MIT License · © 2025 Promptfoo

---

## Architecture

```
Conductor/
├── agency-agents/      ← Layer 1: 156 agent role definitions (The Agency)
├── gstack/             ← Layer 1: 21 workflow skills + 12 binaries (gstack)
├── promptfoo/          ← Layer 1: 85+ validation plugins (Promptfoo)
└── mg-mode-core/       ← Layer 2: The orchestration brain (this is what Conductor adds)
    ├── CONDUCTOR.md      ← Master policy — routing rules, session lifecycle, action classification
    ├── conductor/      ← Single entry point — 4 modes, 15-step orchestration flow
    ├── registry/       ← 156 roles indexed with capability fingerprints + fallback chains
    ├── identity/       ← Agent tokens, 6 authority scopes, entity deduplication
    ├── graph/          ← Semantic code graph — silent init, 5 query types
    ├── map/            ← Pre/during/post execution mapper — 12 cognitive design patterns
    ├── optimizer/      ← Cost routing — budget thresholds, circuit breaker, shadow testing
    ├── governance/     ← 3-question gate (Need? Risk? Owner?) — blocks or approves automation
    ├── profiles/       ← 4 stage profiles — learning through production-strict
    ├── session/        ← Cross-role state persistence — JSONL + optional MCP memory
    └── activation/     ← Bootstrap for 7 IDEs — works in under 15 minutes
```

**Layer 1** is the talent and tooling — three mature open-source projects used as-is, read-only. Conductor never modifies their files.

**Layer 2** is the brain — 11 original components (2,629 lines of markdown) that decide which roles to activate, how much to spend, when to gate actions, and how to persist state across handoffs.

## Quick Start

```bash
# Clone with all Layer 1 libraries (recommended)
git clone --recurse-submodules https://github.com/mechul-eth/conductor.git && cd Conductor

# OR: Clone mg-mode-core only, then fetch Layer 1 on demand
# git clone https://github.com/mechul-eth/conductor.git && cd Conductor
# git submodule update --init agency-agents gstack   # ~33MB
# git submodule update --init promptfoo              # ~750MB — only needed for validation

# Bootstrap (detects your IDE automatically, initializes submodules if needed)
chmod +x mg-mode-core/activation/bootstrap.sh
./mg-mode-core/activation/bootstrap.sh

# Open your IDE agent and say:
# "Activate Conductor"

# Answer 3 onboarding questions:
#   1. Profile: learning / MVP / production-lite / production-strict
#   2. Domain: none / financial / medical / e-commerce / legal / telecom / real-estate / other
#   3. Scenario: startup fast / team iterating / enterprise compliance / incident response

# Start working — Conductor handles routing from here
```

**Supported IDEs:** VS Code + GitHub Copilot, Claude Code, Cursor, Codex CLI, Windsurf, Aider, Gemini CLI.

## How It Works

Every interaction follows this flow:

1. **You say something** in your IDE's agent chat
2. **Conductor** parses your intent → classifies mode (plan / ask / execute / review)
3. **Map** gathers context from the semantic code graph + your session history
4. **Registry** finds the minimum set of specialist roles needed (from the 156 in agency-agents)
5. **Governance** gates the action if your profile requires it (Need? Risk? Owner?)
6. **Identity** issues agent tokens and validates authority scope
7. **Optimizer** picks the cheapest viable cost posture (structure checks before LLM rubrics)
8. **Roles execute** using gstack workflow patterns — monitored for scope drift and loop safety
9. **Promptfoo** runs validation assertions matched to your profile's depth
10. **Session** persists results, costs, handoff context, and completion status
11. **You get a response** with a clear status: `DONE`, `DONE_WITH_CONCERNS`, `BLOCKED`, `NEEDS_CONTEXT`, or `INCIDENT`

### The Four Modes

| Mode | Triggered By | What Happens | Roles Typically Involved |
|------|-------------|-------------|--------------------------|
| **Plan** | "plan", "design", "architect" | Design docs, ADRs, strategic review — no code changes | Software Architect, Product Manager, UX Architect |
| **Ask** | "what is", "explain", "why" | Code intelligence lookup, explanations — read-only | Senior Developer, domain expert |
| **Execute** | "build", "fix", "implement" | Full orchestration: role selection → execution → quality gate | Per-task minimum role set |
| **Review** | "review", "audit", "test" | Code review, security audit, browser-based QA | Code Reviewer, Security Engineer, Reality Checker |

## Profiles

| Profile | Budget Cap | Validation Depth | Governance Gate | Best For |
|---------|-----------|------------------|-----------------|----------|
| `learning` | $5/session | Baseline Group | No | Tutorials, exploration, learning new tools |
| `MVP` | $25/session | Baseline Group | No | Shipping fast, early-stage products |
| `production-lite` | $100/session | Baseline + Security-Deep | Yes | Teams iterating, growing products |
| `production-strict` | $500/session | Full + domain plugins + red-team | Mandatory | Enterprise, regulated industries |

**Baseline Group:** Structure checks, quality assertions, reliability tests, cost bounds.
**Security-Deep Group:** + authorization, injection testing, data leakage, agentic behavior, domain-specific plugins.

## Layer 2 Components

| Component | Purpose |
|-----------|---------|
| [CONDUCTOR.md](mg-mode-core/CONDUCTOR.md) | Master policy — routing algorithm, session lifecycle, action classification, loop safety, bypass prevention |
| [conductor/](mg-mode-core/conductor/README.md) | Single entry point — 4 modes, 15-step orchestration flow, escalation protocol |
| [registry/](mg-mode-core/registry/README.md) | Machine-readable catalog of all 156 roles with capability fingerprints and fallback chains |
| [identity/](mg-mode-core/identity/README.md) | Agent tokens, 6 authority scope levels, entity resolution, concurrent write safety |
| [graph/](mg-mode-core/graph/README.md) | Semantic code graph — silent init, 5 query types, OTel tracing, degraded mode fallback |
| [map/](mg-mode-core/map/README.md) | 3-phase execution mapper (pre/during/post), 12 cognitive design patterns, ADR format |
| [optimizer/](mg-mode-core/optimizer/README.md) | Budget thresholds (70/90/100%), profile-based caps, shadow testing, circuit breaker |
| [governance/](mg-mode-core/governance/README.md) | 3-question gate (Need/Risk/Owner), 7-outcome matrix, bypass protocol |
| [profiles/](mg-mode-core/profiles/README.md) | 4 profiles, 2 validation groups, 8 domain plugins, escalation rules |
| [session/](mg-mode-core/session/README.md) | JSONL state store, optional MCP memory, adversarial write validation, checkpoint/rollback |
| [activation/](mg-mode-core/activation/README.md) | Bootstrap for 7 IDEs, degraded mode spec, MCP Builder pathway |

## Key Design Decisions

- **Markdown-first.** No compiled code in the orchestration layer. The "code" is markdown instruction files — the same format your AI agent already understands natively.
- **Layer 1 is read-only.** mg-mode-core never modifies agency-agents, gstack, or promptfoo. It routes to them, reads their patterns, and invokes their skills.
- **No hallucinated roles.** Every role must exist in the registry, backed by a real file in agency-agents/. The routing engine cannot invent capabilities that don't exist.
- **Deterministic-first.** Start every task with the minimum viable role set. Expand only when a proven dependency requires it. Never activate roles speculatively.
- **User override always available.** Any routing decision, profile selection, governance gate, or action classification can be overridden per task. Overrides are logged with timestamp and reason.
- **No silent scope expansion.** Any action beyond what you asked for is surfaced as a recommendation — never executed automatically. gstack's "Completeness Principle" is intercepted and shown to you, not auto-applied.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute. Please read the [Code of Conduct](CODE_OF_CONDUCT.md) first.

To report a security issue, see [SECURITY.md](SECURITY.md) — do not open a public issue.

## License

Conductor's orchestration layer (mg-mode-core/) is [MIT licensed](LICENSE).

Each Layer 1 project retains its own license:

| Directory | License | Copyright | Upstream |
|-----------|---------|-----------|----------|
| `agency-agents/` | MIT | © 2025 AgentLand Contributors | [msitarzewski/agency-agents](https://github.com/msitarzewski/agency-agents) |
| `gstack/` | MIT | © 2026 Garry Tan | [garrytan/gstack](https://github.com/garrytan/gstack) |
| `promptfoo/` | MIT | © 2025 Promptfoo | [promptfoo/promptfoo](https://github.com/promptfoo/promptfoo) |

## Acknowledgments

Conductor wouldn't exist without the work of [Mike Sitarzewski](https://github.com/msitarzewski), [Garry Tan](https://github.com/garrytan), and the [Promptfoo](https://github.com/promptfoo) team. Their open-source projects are the foundation this orchestrator stands on. We built the brain — they built the body.
