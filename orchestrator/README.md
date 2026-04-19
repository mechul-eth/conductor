# orchestrator/ — Conductor Runtime (optional)

> The orchestrator is the bash runtime that turns Conductor from "context loaded into your IDE" into "an unattended pipeline runner." It dispatches tasks to roles, runs quality gates, retries on failure, escalates on stuck, and persists state across sessions.

You don't need it to use Conductor. Most teams start with the markdown context loaded into VS Code / Claude Code / Cursor and never touch this directory. Reach for it when you want unattended multi-phase pipelines, scheduled resumption, or strict auditability.

---

## Architecture

```
orchestrator/
├── README.md              ← This file
├── START_HERE.md          ← Setup walkthrough
├── conductor.sh           ← The single entry point — start / resume / status / halt
├── tasks.example.json     ← Example task queue — copy to tasks.json and edit
├── bin/                   ← Helper scripts (extraction, validation, etc.)
├── lib/                   ← Modular bash helpers — sourced by conductor.sh
│   ├── log.sh             ← Structured logging with credential redaction
│   ├── lock.sh            ← Master lock + state lock with stale-TTL recovery
│   ├── state.sh           ← Append-only JSONL state ledger with idempotency
│   ├── notify.sh          ← Sprint boundaries, escalations, go-live notification
│   ├── preflight.sh       ← Environment readiness checks
│   ├── gates.sh           ← Quality gate runner (A through H + custom)
│   ├── dispatch.sh        ← Role dispatch (parent-agent or CLI mode)
│   ├── blocker.sh         ← 3-role consensus on blocked tasks
│   ├── compact.sh         ← Auto-compact between tasks
│   └── apple_grade.sh     ← World-standard quality check
├── roles/                 ← Role manifest + generic fallback
│   ├── manifest.json      ← Maps task role keys → conductor-core/business/roles/*.md (and external URLs)
│   └── _generic.md        ← Fallback when no role matches
├── prompts/               ← Lean — only the dispatch envelope template lives here
├── gates/                 ← Optional per-task custom gate scripts (gates/A_<task_id>.sh, etc.)
├── checkpoints/           ← Per-task dispatch envelopes + role outputs (gitignored)
├── logs/                  ← Per-day run logs (gitignored)
├── locks/                 ← Master + state locks (gitignored)
└── blockers/              ← Per-task blocker context for consensus rounds (gitignored)
```

The state machine, gate matrix, dispatch contract, and lock protocol are documented inline in the source. The most important contracts are:

| Concept | Source | What it guarantees |
|---------|--------|--------------------|
| State ledger | `lib/state.sh` | Append-only JSONL, atomic per write, idempotent within 60s |
| Locks | `lib/lock.sh` | Master lock prevents dual orchestrators; stale locks auto-break |
| Dispatch | `lib/dispatch.sh` | Roles get a re-grounded envelope with the last 3 COMPLETED summaries |
| Gates | `lib/gates.sh` | A=topology, B=build, C=test, D=e2e/security, E=sprint, G=a11y, H=acceptance, FINAL=release |
| Apple-grade | `lib/apple_grade.sh` | World-standard quality reflection mandatory before COMPLETED |
| Consensus | `lib/blocker.sh` | 3 roles in parallel; 2-of-3 fix applied if convergent |

---

## Status State Machine

```
PENDING ─→ IN_PROGRESS ─→ COMPLETED ─→ next task
                    ↘
                     PARTIAL ──retry≤3──→ IN_PROGRESS
                          ↘
                           BLOCKED ──→ CONSENSUS ──×3──→ ESCALATED
                                            ↘
                                             COMPLETED (consensus fix)
```

Special states: `HALT` (manual), `ALL_DONE` (final), `ESCALATED` (human), `INCIDENT` (security halt).

---

## Quality Gates

Per task, the `gates` array in `tasks.json` declares which gates run. Letters are conventions — define your own in `lib/gates.sh` or per-task scripts in `gates/`.

| Gate | Default name | When it runs | Default check |
|------|--------------|--------------|---------------|
| A | topology | Always | Schema valid, files exist, FK ordering |
| B | build | Build-affecting tasks | `npm run typecheck`, `npm run build` (override per project) |
| C | test | Test-related tasks | `npm test`, `pytest`, etc. |
| D | e2e / security | Integration tasks | curl health checks, RLS isolation, credential scan |
| E | sprint final | End-of-sprint task | All sprint tasks COMPLETED |
| F | apple-grade | Frontend tasks (S3+) | World-standard reflection answered |
| G | accessibility | Frontend tasks | axe-core / Lighthouse a11y ≥ 90 |
| H | acceptance | **Always (implicit)** | Every acceptance criterion in `tasks.json` reports `[✓]` |

Per-task custom validators: drop `gates/A_<task_id>.sh` (etc.) and the runtime will execute it.

---

## Dispatch Modes

`lib/dispatch.sh` supports two execution modes (`CONDUCTOR_DISPATCH_MODE` env var, default `auto`):

| Mode | When | Mechanism |
|------|------|-----------|
| `parent_agent` | Interactive IDE session is alive | Conductor writes `checkpoints/DISPATCH_REQUESTED` with envelope + output path. Parent IDE polls, runs the Task tool, writes the output, deletes the marker. |
| `cli` | Cron resumer / unattended | Conductor invokes `claude --print --dangerously-skip-permissions < envelope > output_file` directly. Same envelope, same parser. |

The dispatch parser **never assumes success**. Every role reply must end with `TASK_RESULT: PASS` or `TASK_RESULT: FAIL` on its own line. Anything else → PARTIAL → retry.

---

## Marker File Protocol (parent-agent mode)

| Marker | Direction | Meaning |
|--------|-----------|---------|
| `DISPATCH_REQUESTED` | conductor → parent | Envelope is ready; parent must run Task tool, write OUTPUT_FILE, delete marker |
| `CONSENSUS_REQUESTED` | conductor → parent | Task is BLOCKED; parent must dispatch 3 subagents in parallel, synthesize 2-of-3, apply fix |
| `COMPACT_REQUESTED` | conductor → parent | A task just COMPLETED; parent runs `/compact` then deletes marker |
| `ESCALATED_<task>.md` | conductor → user | Consensus exhausted; halt and notify |
| `RELEASE_GREEN` | conductor → user | Final gate passed |

---

## Cross-References

- `conductor-core/CONDUCTOR.md` — supreme policy (orchestrator obeys unconditionally)
- `conductor-core/business/ROUTING.md` — role wiring (orchestrator dispatch reads this)
- `conductor-core/business/roles/` — internal role definitions (referenced by `roles/manifest.json`)
- `conductor-core/phases/` — phase templates (turn into `tasks.json` entries)
- `conductor-core/canonical_prompt.md` — pipeline overlay (orchestrator state mirrors `pipeline-state.json`)
