# Activation — Universal IDE Bootstrap Kit

> Any IDE. Any model. ≤15 minutes to first success. One instruction file, zero manual config.

## Design Advisors (Layer 1 — do not rebuild)
- `gstack/SKILL.md` — skill discovery, proactive mode toggle
- `gstack/bin/gstack-config` — config persistence (proactive, telemetry, update-checks)
- `gstack/CLAUDE.md` — Claude Code / Codex dev environment
- `agency-agents/` — 156 agent role definitions across 13 domains
- `promptfoo/` — 85+ validation plugins

## Core Guarantees

1. **Any IDE.** Conductor works in every agent-capable IDE — no IDE lock-in.
2. **≤15 min first success.** From clone to working orchestration in 15 minutes or less.
3. **Proactive disabled first.** Layer 1 proactive suggestions are disabled on activation so Layer 2 controls routing.
4. **Graceful degradation.** Missing capabilities fall back to the next best option, never hard fail.
5. **Zero model lock-in.** Works with any foundation model that supports the IDE's agent protocol.

---

## Supported Environments

| IDE | Instruction File | Agent Protocol | Status |
|-----|-----------------|----------------|--------|
| VS Code + GitHub Copilot | `.github/copilot-instructions.md` | Copilot Chat | Tier 1 |
| Claude Code | `CLAUDE.md` | Claude native | Tier 1 |
| Cursor | `.cursorrules` | Cursor Agent | Tier 1 |
| Codex CLI | `AGENTS.md` or `codex.md` | Codex native | Tier 1 |
| Windsurf | `.windsurfrules` | Cascade Agent | Tier 2 |
| Aider | `.aider.conf.yml` + convention file | Aider native | Tier 2 |
| Gemini CLI | `GEMINI.md` | Gemini native | Tier 2 |
| OpenCode | `AGENTS.md` | OpenCode native | Tier 2 |
| Antigravity | IDE-specific config | Native | Tier 3 |

**Tier definitions:**
- Tier 1: Full feature parity. All 12 components active.
- Tier 2: Core features active. Some components may run in degraded mode.
- Tier 3: Basic orchestration. Role routing and session state available.

---

## Bootstrap Sequence

```
STEP 1 — Clone (user)
  git clone --recurse-submodules https://github.com/mechul-eth/conductor.git
  cd Conductor

STEP 2 — Generate IDE instruction file (automatic)
  activation/ detects current IDE environment
  activation/ generates the appropriate instruction file:
    → .github/copilot-instructions.md   (VS Code + Copilot)
    → CLAUDE.md                          (Claude Code)
    → .cursorrules                       (Cursor)
    → .windsurfrules                     (Windsurf)
    → .aider.conf.yml                    (Aider)
    → GEMINI.md                          (Gemini CLI)

STEP 3 — Disable Layer 1 proactive mode
  gstack-config set proactive false
  (prevents Layer 1 from suggesting roles before Layer 2 routes)

STEP 4 — Run onboarding (first session)
  profiles/ asks the 3 onboarding questions:
    1. What stage? → profile selection
    2. What domain? → domain plugin activation
    3. What scenario? → NEXUS mode sizing

  business/ intelligence bootstrap:
    → Detect: Does workspace contain existing source files beyond mg-mode-core/?
    → IF EXISTING CODEBASE:
        Scan README.md, package.json, configs, docs/ (read-only)
        → Present extracted intelligence to user as a batch
        → User approves, corrects, or skips
        → Write approved entries to business/ files
        → Skip onboarding questions already answered by the scan
    → IF FRESH PROJECT:
        4. "What are you building?" → writes to business/core.md (with user approval)
        5. "Who is it for?" → writes to business/core.md (with user approval)
        6. "Who are your main competitors?" → writes to business/market.md (optional — user can skip)

STEP 5 — Initialize components
  session/ → state store initialized
  graph/ → workspace scan started (non-blocking)
  identity/ → agent pool registered
  business/ → directory and template files confirmed present
  → READY

Total: ≤15 minutes for Step 1–5.
```

---

## IDE Instruction File Template

Every IDE instruction file follows this structure:

```markdown
# Conductor — Orchestration Layer

You are operating under Conductor, a two-layer orchestration system.

## Layer 1 — Libraries (read-only, invoke directly)
- agency-agents/: 156 agent role definitions across 13 domains
- gstack/: 21+ workflow skills with binary entry points
- promptfoo/: 85+ validation and red-team plugins

## Layer 2 — Brain (mg-mode-core/)
- CONDUCTOR.md: Master policy and routing rules
- identity/: Agent trust and authorization
- graph/: Semantic code graph
- map/: Pre/during/post execution planning
- optimizer/: Cost routing and circuit breaker
- governance/: Automation value gate
- profiles/: Stage-aware configuration
- session/: Cross-role state persistence
- business/: Per-project business intelligence — user, product, market (created on first activation)
- activation/: This bootstrap (already running)

## Behavioral Rules
1. NEVER invent a role. Use only roles defined in agency-agents/.
2. ALWAYS run through map/ before executing. Pre-execution planning is mandatory.
3. RESPECT the active profile's budget caps, validation groups, and gate requirements.
4. PERSIST results to session/ after every task completion.
5. VALIDATE through promptfoo/ when the profile requires it.
6. ROUTE cost decisions through optimizer/ — cheapest viable model first.
7. ASK before acting when blast radius > 5 files or action is irreversible.

## Active Configuration
- Profile: {profile}
- Domain: {domain}
- Scenario: {scenario}
- NEXUS Mode: {nexus_mode}
- Proactive: false (Layer 2 controls routing)

@mg-mode-core/CONDUCTOR.md
```

---

## IDE-Specific Adaptations

### VS Code + GitHub Copilot
```
File: .github/copilot-instructions.md
Notes:
  - Copilot Chat loads instructions from .github/copilot-instructions.md
  - @workspace references work natively
  - MCP tools available through VS Code MCP server config
  - File edits via Copilot Edits or inline suggestions
```

### Claude Code
```
File: CLAUDE.md (project root)
Notes:
  - Claude Code loads CLAUDE.md automatically on project open
  - @file references for context injection
  - Native tool use (bash, file edit, search)
  - Sub-agent spawning supported
  - MCP servers configurable in project settings
```

### Cursor
```
File: .cursorrules (project root)
Notes:
  - Cursor loads .cursorrules on project open
  - @file and @codebase for context
  - Composer mode for multi-file edits
  - Agent mode for autonomous execution
```

### Codex CLI
```
File: AGENTS.md or codex.md (project root)
Notes:
  - Codex reads AGENTS.md for project instructions
  - Sandboxed execution environment
  - Parallel task execution supported
  - --output-format stream-json for monitoring
```

### Windsurf
```
File: .windsurfrules (project root)
Notes:
  - Cascade agent mode for autonomous flow
  - Memory system for cross-session context
  - Flows for multi-step task orchestration
```

### Aider
```
File: .aider.conf.yml + CONVENTIONS.md
Notes:
  - Aider reads conventions from CONVENTIONS.md
  - /architect mode for planning
  - /code mode for implementation
  - Git integration is native (auto-commit)
  - Model switching via --model flag
```

### Gemini CLI
```
File: GEMINI.md
Notes:
  - Gemini CLI reads project context from GEMINI.md
  - Google Cloud integration native
  - Grounding with Google Search available
```

---

## Degraded Mode Specification

When a feature is unavailable in a given IDE:

| Feature | Degraded Behavior | Affected IDEs |
|---------|-------------------|---------------|
| MCP tool access | Fall back to CLI commands | Aider, some Tier 3 |
| Sub-agent spawning | Sequential role execution | Aider, Gemini CLI |
| Native file search | Use grep/find via terminal | Tier 3 |
| Inline code edit | Full file replacement | Tier 3 |
| Browser automation | Skip browser-based QA | All without Playwright |
| Session persistence via MCP | Fall back to JSONL file | IDEs without MCP |

**Degradation is silent.** The user sees the same interface. Conductor adapts internally.

---

## MCP Builder Custom Tool Pathway (G68)

For IDEs supporting MCP, activation/ configures custom tools:

```json
{
  "mcpServers": {
    "conductor": {
      "command": "npx",
      "args": ["-y", "conductor-mcp-server"],
      "env": {
        "CONDUCTOR_ROOT": "/path/to/Conductor"
      }
    }
  }
}
```

Custom tools exposed via MCP:
- `conductor_route` — route a task to the optimal role
- `conductor_session` — read/write session state
- `conductor_validate` — run promptfoo assertions
- `conductor_cost` — check budget status
- `conductor_graph` — query semantic code graph

---

## Quick Start Commands

```bash
# Clone and enter
git clone --recurse-submodules https://github.com/mechul-eth/conductor.git && cd Conductor

# Bootstrap (generates IDE instruction file + runs onboarding)
./mg-mode-core/activation/bootstrap.sh

# Or manually:
# 1. Copy the IDE instruction file template above into your IDE's config
# 2. Open a chat with your IDE's agent
# 3. Say: "Read mg-mode-core/CONDUCTOR.md and activate Conductor"
# 4. Answer the 3 onboarding questions
# 5. Start working
```

---

## Integration Points

| Component | How activation/ interacts |
|-----------|--------------------------|
| `profiles/` | Triggers 3-question onboarding on first activation || `business/` | Triggers 3-question BI onboarding after profiles/ onboarding; confirms template files present || `session/` | Initializes state store after onboarding |
| `graph/` | Triggers non-blocking workspace scan |
| `identity/` | Registers agent pool with capability fingerprints |
| `gstack-config` | Sets `proactive: false` to disable Layer 1 suggestions |
| `optimizer/` | Loads budget caps from selected profile |
| `conductor/` | After activation, conductor/ takes over orchestration |
