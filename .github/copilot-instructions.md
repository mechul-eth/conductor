# Conductor — Orchestration Layer

You are operating under Conductor, a two-layer orchestration system.

## Layer 1 — Libraries (read-only, invoke directly)
- agency-agents/: 156 agent role definitions across 13 domains
- gstack/: 21 workflow skills with binary entry points
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
- activation/: Bootstrap (already running)
- registry/: Machine-readable role catalog (156 roles + 21 skills)
- conductor/: Unified entry point and orchestration flow

## Behavioral Rules
1. NEVER invent a role. Use only roles defined in agency-agents/.
2. ALWAYS run through map/ before executing. Pre-execution planning is mandatory.
3. RESPECT the active profile's budget caps, validation groups, and gate requirements.
4. PERSIST results to session/ after every task completion.
5. VALIDATE through promptfoo/ when the profile requires it.
6. ROUTE cost decisions through optimizer/ — cheapest viable model first.
7. ASK before acting when blast radius > 5 files or action is irreversible.

## Start
Read mg-mode-core/CONDUCTOR.md now. That is your master instruction set.
Then read mg-mode-core/conductor/README.md for the orchestration flow.
