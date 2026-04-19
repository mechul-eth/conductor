# Changelog

All notable changes to Conductor are documented here.

Layer 1 components (agency-agents, gstack, promptfoo) maintain their own changelogs in their respective directories.

## [1.2.0] — 2026-04-19

Friends-and-community-ready preview release. Big structural pass: the brain stays the same; the per-project contract layer gets much richer so a team can clone, fill in a few files, and have a fully wired Conductor without writing any code.

### Added

- `conductor-core/canonical_prompt.md` — optional pipeline overlay template. Declares scope, source-of-truth hierarchy, and phase sequence for multi-phase deliveries. Skip for ad-hoc work.
- `conductor-core/phases/` — 7 generic phase templates (preflight/scope-map, parity/scaffold, write paths, read paths, realtime/triggers, polish, release gate) + phase README.
- `conductor-core/business/ROUTING.md` — the role-to-context routing contract. Teams edit this to wire Conductor to their team.
- `conductor-core/business/FRAME_CONTROL_ALGORITHM.md` — deterministic frame lock + orphan-prevention rule.
- `conductor-core/business/roles/` — 14 generic role templates + `_template.md` + `README.md`. Internal roles live here.
- `conductor-core/business/{api|backend|frontend|database|integration|ai-usage|release-readiness}-intelligence/` — 7 intelligence domain READMEs with foundation templates. Each is a first-class control-plane dependency at release time.
- `conductor-core/business/segments/` and `conductor-core/business/research/` — growth templates.
- `conductor-core/activation/FIRST_RUN.md` — step-by-step runbook the IDE agent follows on first activation: scan repo, ask the gaps, wire `ROUTING.md`, write `business/` with user approval.
- `conductor-core/activation/QUESTIONS.md` — onboarding question bank (profile-aware limits).
- `conductor-core/activation/SCAN_CHECKLIST.md` — what the agent reads from an existing repo to pre-populate `business/`.
- `conductor-core/activation/vscode/` — first-class VS Code kit: copilot-instructions, settings, extensions, tasks, mcp.example.
- `conductor-core/activation/{claude-code,cursor,codex,windsurf,aider,gemini-cli}/` — per-IDE adapters.
- `orchestrator/` — optional bash runtime for unattended multi-phase pipelines. `conductor.sh` entry, `lib/*.sh` helpers (log, lock, state, notify, preflight, gates, dispatch, blocker, compact, apple_grade), `roles/manifest.json` (internal local files + external URL references — both first-class), `tasks.example.json`, per-task gate hooks.
- `.github/workflows/ci.yml` — shellcheck, JSON validation, markdown lint, orphan-prevention check.
- `.github/workflows/release.yml` — tag-triggered GitHub Releases driven by `VERSION` + `CHANGELOG.md`.
- `.github/CODEOWNERS`, `.github/ISSUE_TEMPLATE/config.yml`.
- `VERSION` (0.1.0) and `.editorconfig`.

### Changed

- `conductor-core/README.md` — diagram + component table expanded to reflect new phases, canonical_prompt, intelligence domains, and the optional `orchestrator/` sibling.
- `conductor-core/business/README.md` — rewritten as a plug-in kit with a 7-step "how to plug Conductor in" guide and a reading order by role.
- `conductor-core/activation/README.md` — front-linked to runbook + question bank + scan checklist + per-IDE directories. Zero-assumptions principle stated explicitly.
- `.github/pull_request_template.md` — checklist updated to cover `business/`, `phases/`, `orchestrator/`.

### Principles reinforced

- **Zero assumptions.** Conductor ships without any knowledge of the project's industry or terminology. It learns from the user via the first-run runbook.
- **Internal and external roles are both first-class.** Internal in `business/roles/`. External via URL in `orchestrator/roles/manifest.json`. Both obey Conductor policies unconditionally.
- **No orphans.** Every new artifact must be referenced from a `README`, `ROUTING.md`, and at least one gate. CI enforces this.

### Launch polish

- `Makefile` at the repo root with shortcuts for `preflight`, `start`, `resume`, `status`, `halt`, `validate-state`, `lint`, `lint-bash`, `lint-json`, `lint-md`, `orphan-check`, `test`, `version`. `SHELL := /bin/bash` so process substitution works.
- `examples/filled-business/` — fully filled-in `business/` for a fictional B2B SaaS (Northwind Notes). Newcomers see what "done with onboarding" looks like.
- `.github/FUNDING.yml` — enables the GitHub Sponsors button.
- README badges: License, Version, CI, PRs Welcome, Code of Conduct.
- README "Known Limitations" section — honest about what Conductor doesn't do (no hosted runtime, English-first prompts, no metrics dashboard, etc.).
- CI markdown-lint is now strict (removed `|| true`) and covers `examples/**/*.md`.
- `bootstrap.sh` now copies from the per-IDE adapter directories instead of an inline stale template; for VS Code it also copies `.vscode/{settings,extensions,tasks}.json` and for Aider it copies `.aider.conf.yml`.

### Bug fixes (post-audit)

- `VERSION` corrected from `0.1.0` → `1.2.0` (was a regression vs. existing `1.1.0`).
- Root `.github/copilot-instructions.md` overwritten with the current adapter content (was stale).
- Dispatch envelope no longer emits `[ OR x]` literal in the output schema; now emits `[ ]` with an explicit instruction to replace with `[✓]` or `[x]`.
- `gate_h_acceptance` cleaned up — removed dead variable and pointless `awk '{print}'`; failure log now prints the offending criterion lines.

---

## [1.1.0] — 2026-03-21

### Added
- **CODE_OF_CONDUCT.md** — Plain-language contributor code of conduct
- **SECURITY.md** — Vulnerability reporting policy, scope definition, AI-specific security notes
- **Git submodule structure** — Layer 1 libraries (agency-agents, gstack, promptfoo) configured as git submodules pointing to their upstream repositories

### Improved
- `CONTRIBUTING.md` — Rewritten with plain language and accurate test instructions
- Documentation accuracy pass across all conductor-core component READMEs

### Layer 1 State (March 2026)
- agency-agents: 158+ roles across 13 domains
- gstack: v0.9.0, 21 skills, 12 binaries
- promptfoo: part of OpenAI (March 2026), 85+ plugins, still MIT

---

## [1.0.0] — 2025-07-18

### Added
- **CONDUCTOR.md** — Master brain with routing algorithm, session lifecycle, action classification, loop safety, and bypass prevention (371 lines)
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
