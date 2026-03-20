# Changelog

All notable changes to MG_MODE (Layer 2 — mg-mode-core) are documented here.

Layer 1 components (agency-agents, gstack, promptfoo) maintain their own changelogs in their respective directories.

## [1.1.0] — 2026-03-21

### Added
- **CODE_OF_CONDUCT.md** — Plain-language contributor code of conduct
- **SECURITY.md** — Vulnerability reporting policy, scope definition, AI-specific security notes
- **Git submodule structure** — Layer 1 libraries (agency-agents, gstack, promptfoo) configured as git submodules pointing to their upstream repositories

### Fixed
- `mg-mode-core/README.md` — Updated MG_MODE.md line count to 777 (was 724)
- `.github/pull_request_template.md` — Updated test command to `mg-mode-test-runner.sh` with 72 checks (was `test_routing.py` with 9)
- `CONTRIBUTING.md` — Rewritten: plain language, accurate test instructions, added links to CODE_OF_CONDUCT, SECURITY

### Layer 1 State (March 2026)
- agency-agents: 158+ roles across 13 domains
- gstack: v0.9.0, 21 skills, 12 binaries
- promptfoo: part of OpenAI (March 2026), 85+ plugins, still MIT

---

## [1.0.0] — 2025-07-18

### Added
- **MG_MODE.md** — Master brain with routing algorithm, session lifecycle, action classification, loop safety, and bypass prevention (371 lines)
- **conductor/** — Unified entry point with 4 modes (plan/ask/execute/review), 15-step orchestration flow, escalation protocol
- **registry/** — Machine-readable catalog of 156 roles across 13 domains with capability fingerprints, fallback chains, and NEXUS mode composition
- **identity/** — Agent tokens, 6 authority scope levels, entity resolution, concurrent write safety
- **graph/** — Semantic code graph with 5 query types, silent initialization, OTel tracing, degraded mode fallback
- **map/** — 3-phase execution mapper (pre/during/post), 12 cognitive design patterns, ADR format, strategic reviews
- **optimizer/** — Budget thresholds (70/90/100%), profile-based caps ($5–$500), shadow testing at 5% dark-launch, circuit breaker
- **governance/** — 3-question gate (Need/Risk/Owner), 7-outcome matrix, bypass protocol, data anomaly routing
- **profiles/** — 4 profiles (learning, MVP, production-lite, production-strict), 2 validation groups, 8 domain plugins
- **session/** — JSONL state store, optional MCP memory, adversarial write validation, checkpoint/rollback
- **activation/** — Bootstrap script for 7 IDEs, degraded mode spec, MCP Builder pathway
- Top-level LICENSE (MIT), README.md, CONTRIBUTING.md
- Routing test harness with 9 tests covering single-role pick, multi-role NEXUS, tier filtering, fallback chains, session switching, governance gates, and incident escalation

### Layer 1 Versions at Release
- agency-agents: 156 roles, 13 domains
- gstack: v0.9.0, 21 skills, 12 binaries
- promptfoo: 85+ plugins, 50+ assertions
