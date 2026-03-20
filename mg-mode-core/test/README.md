# Conductor Test Suite

Validation framework for Conductor orchestration logic.

## Files

| File | Purpose |
|------|---------|
| **conductor-test-runner.sh** | Automated test suite (15 groups, 72 checks) |
| **CONDUCTOR_VALIDATION.md** | Validation framework: scenarios, schemas, manual checklist |
| **test_routing.py** | Python routing test harness for role selection + session logic |

## Quick Start

```bash
bash conductor-test-runner.sh
```

Output: color-coded pass/fail per check, final score out of 72.

---

## Test Coverage (15 Groups, 72 Checks)

| # | Group | Checks | What It Validates |
|---|-------|--------|-------------------|
| 1 | Profile Selection | 4 | All 4 modes + fallback to learning |
| 2 | Role Routing | 5 | Algorithm + NEXUS modes + fingerprints schema |
| 3 | Handoff Schema | 3 | 6 schema sections + prime directives |
| 4 | Loop Safety | 5 | 3-strike + semantic detection + graph timeout |
| 5 | Scope Drift | 3 | CLEAN/CREEP/MISSING verdicts + timing |
| 6 | Blast Radius | 4 | >5 files gate + reclassification + A/B/C |
| 7 | Quality Gates | 3 | Baseline/Security-Deep + cross-model review |
| 8 | Layer 1 Override | 5 | Supreme policy + re-grounding template |
| 9 | Investigation | 4 | 6 bug patterns + 3-strike hypothesis |
| 10 | Layer 2 Components | 12 | All 11 component dirs + CONDUCTOR.md Brain file |
| 11 | Session Format | 3 | JSONL schema + event types + concurrency |
| 12 | Bypass Prevention | 2 | Enforcement levels + audit format |
| 13 | Business Intelligence | 7 | Templates, confidence tags, approval rules, routing, profile depth, pre-ship review |
| 14 | Existing Repo Bootstrap | 7 | Auto-scan, batch approval, idempotency, activation, profile extensions, scan depth |
| 15 | Trigger Contracts | 5 | Mode trigger registry, conductor matching rules, gstack trigger registry, generated Claude/Codex skill docs |

---

## Validation Scenarios

Eight manual scenarios in CONDUCTOR_VALIDATION.md:

1. **Simple Task** — typo fix → 1 role, no NEXUS overhead
2. **Compound Task** — payment gateway → 4 roles, dependency order, 3 handoffs
3. **Scope Drift** — alignment fix with over-delivery → SCOPE_CREEP verdict
4. **3-Strike Escalation** — 3 failed hypotheses → BLOCKED + user choices
5. **Production-Strict Gate** — governance mandatory, Security-Deep activated
6. **Business Intelligence** — profile-aware onboarding (learning→1 question, production-strict→mandatory follow-ups + pre-ship blocks)
7. **Existing Repo Bootstrap** — profile-aware scan depth (quick scan → deep scan with compliance/security)
8. **Trigger Contracts** — mode registry + gstack suggestion triggers stay aligned across generated outputs

---

## Routing Test Harness

```bash
python3 test_routing.py
```

Covers ~28 of 156 registered roles. Validates role picking, fallback chains, NEXUS sizing, and session state carry-over.

---

## Layer 2 Components Validated

```
mg-mode-core/
├── CONDUCTOR.md       ← Brain & policy
├── identity/        ← Agent trust
├── graph/           ← Semantic code graph
├── map/             ← Pre/during/post mapper
├── optimizer/       ← Cost routing
├── governance/      ← Gate keeper
├── profiles/        ← Stage config
├── session/         ← State persistence
├── activation/      ← Bootstrap
├── registry/        ← Role catalog
├── conductor/       ← Entry point
└── business/        ← Per-project intelligence
```

---

*Test framework v1.2 — Conductor v1.0*
