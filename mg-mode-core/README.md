# mg-mode-core — Layer 2 Orchestration Brain

> 156 roles. 21 skills. 85+ validators. One brain that knows when to use each one.

## Architecture

```
Conductor/
├── agency-agents/         ← Layer 1: 156 agent roles (read-only)
├── gstack/                ← Layer 1: 21 workflow skills (read-only)
├── promptfoo/             ← Layer 1: 85+ validation plugins (read-only)
└── mg-mode-core/          ← Layer 2: THIS — the orchestration brain
    ├── CONDUCTOR.md         ← Master policy, routing rules, decision authority
    ├── identity/          ← Agent identity, trust, entity deduplication
    ├── graph/             ← Semantic code graph for connected reasoning
    ├── map/               ← Pre/during/post execution mapper + prompt gen
    ├── optimizer/         ← Cost routing, circuit breaker, shadow testing
    ├── governance/        ← Automation value/risk/ownership gate
    ├── profiles/          ← Stage-aware onboarding + budget profiles
    ├── session/           ← Cross-role state persistence
    ├── activation/        ← Universal IDE bootstrap kit
    ├── registry/          ← Machine-readable role catalog (156 roles + 21 skills)
    ├── conductor/         ← Unified entry point + orchestration flow
    └── business/          ← Per-project business intelligence
```

## Quick Start

```bash
# 1. Clone
git clone --recurse-submodules https://github.com/mechul-eth/conductor.git && cd Conductor

# 2. Bootstrap (make executable first: chmod +x mg-mode-core/activation/bootstrap.sh)
./mg-mode-core/activation/bootstrap.sh

# 3. Open your IDE agent and say: "Activate Conductor"
# 4. Answer the 3 onboarding questions
# 5. Start working
```

Supports: VS Code + Copilot, Claude Code, Cursor, Codex CLI, Windsurf, Aider, Gemini CLI.

## Components

| Component | Lines | Purpose |
|-----------|-------|---------|
| [CONDUCTOR.md](CONDUCTOR.md) | 777 | Supreme policy. Session lifecycle. Routing algorithm. Action classification. Loop safety. Business intelligence. Bypass prevention. |
| [identity/](identity/README.md) | 115 | Agent tokens. Authority scopes (6 levels). Entity resolution. Concurrent write safety. RBAC validation. |
| [graph/](graph/README.md) | 147 | Silent initialization. 5 query types. Luhmann validation. OTel tracing. Degraded mode fallback. |
| [map/](map/README.md) | 266 | 3-phase mapper (pre/during/post). 12 design cognitive patterns. ADR format. Workflow registry. Strategic reviews. |
| [optimizer/](optimizer/README.md) | 178 | Budget thresholds (70/90/100%). Profile caps ($5–$500). Shadow testing (5% dark-launch). Circuit breaker. |
| [governance/](governance/README.md) | 180 | 3-question gate (Need/Risk/Owner). 7-outcome matrix. Bypass protocol. Data anomaly routing. Tool adoption TCO. |
| [profiles/](profiles/README.md) | 202 | 4 profiles (learning → production-strict). 2 validation groups. 8 domain plugins. Escalation rules. |
| [session/](session/README.md) | 202 | JSONL state store. Optional MCP memory. Adversarial write validation. Checkpoint/rollback. Session close. |
| [activation/](activation/README.md) | 288 | 9 IDE environments. Bootstrap script. Existing repo auto-scan. Degraded mode spec. MCP Builder pathway. ≤15-min first success. |
| [registry/](registry/README.md) | 370 | 156 roles with capability fingerprints. 21 workflow skills. Fallback chains. NEXUS mode composition. |
| [conductor/](conductor/README.md) | 337 | 4 modes (plan/ask/execute/review). 15-step orchestration flow. Business context injection. Loop safety. Escalation protocol. |
| [business/](business/README.md) | 259 | Per-project intelligence. User profile, business model, market data. Auto-learn from existing repos. Confidence tagging. Layer 1 role integration. |
| **Total** | **3,268** | |

## How It Works

1. **You say something** in your IDE's agent chat
2. **Conductor** parses your intent → classifies mode (plan/ask/execute/review)
3. **Map** gathers context from the graph + your session history
4. **Business** supplies project-specific context (industry, users, constraints)
5. **Registry** finds the minimum set of roles needed
6. **Governance** gates the action if your profile requires it
7. **Identity** issues tokens, validates authority
8. **Optimizer** picks the cheapest viable cost posture
9. **Roles execute** — monitored for scope drift
10. **Promptfoo** runs validation assertions (per your profile)
11. **Session** persists results, costs, and handoff context
12. **You get a response** with a clear completion status

## Profiles

| Profile | Budget Cap | Validation | Gate Required | Best For |
|---------|-----------|------------|---------------|----------|
| `learning` | $5/session | Baseline only | No | Tutorials, exploration |
| `MVP` | $25/session | Baseline only | No | Startup fast, shipping quick |
| `production-lite` | $100/session | Baseline + Security-Deep | Yes (3-question) | Team iterating, growing |
| `production-strict` | $500/session | Full + domain plugins | Yes (mandatory) | Enterprise, regulated |

## NEXUS Modes

| Mode | Agent Count | When |
|------|-------------|------|
| `Micro` | 5–10 | Single feature, focused work |
| `Sprint` | 15–25 | Full sprint cycle with planning and shipping |
| `Full` | All 156+ | Enterprise-scale, multi-domain initiatives |

## Key Design Decisions

- **Markdown-first.** The "code" is markdown instruction files — the same format as Layer 1 agents and skills. This is an AI-native orchestrator, not a compiled binary.
- **Layer 1 is read-only.** mg-mode-core/ never modifies agency-agents/, gstack/, or promptfoo/. It invokes them.
- **Profiles gate everything.** Budget caps, validation groups, governance gates, and domain plugins are all controlled by which profile you select.
- **No hallucinated roles.** Every role must exist in registry/ (backed by a real file in agency-agents/). The routing engine cannot invent capabilities.
- **Fallback chains.** Every role has a declared fallback. If your preferred architect is unavailable, the next best option is known in advance.
