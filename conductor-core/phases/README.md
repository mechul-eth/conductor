# conductor-core/phases/ — Phase Templates

> A pipeline is a sequence of phases. Each phase has one goal, a defined entry condition, an exit condition, and a small set of acceptance criteria. Phase files are the deterministic skeleton Conductor follows when running an end-to-end delivery.

## What a Phase Is

A phase is a self-contained unit of work with:

- **Mission** — one paragraph: what this phase ships.
- **Roster** — the minimum role set Conductor activates for this phase.
- **Entry preflight** — the checks that must pass before the phase begins (usually inherited from `canonical_prompt.md`).
- **Steps** — the deterministic sequence the roster follows.
- **Exit criteria** — measurable outcomes that flip the phase from `PENDING` to `GREEN`.
- **Regression rules** — what counts as a regression that BLOCKS subsequent phases.

## Default Pipeline (template)

| Phase | File | Mission |
|------:|------|---------|
| 0 | `phase-0-preflight-and-scope-map.md` | Verify environment + map the scope before any code change |
| 1 | `phase-1-parity-scaffold.md` | Bring the project to a known baseline (UI parity, scaffold) |
| 2 | `phase-2-write-paths.md` | Wire the P0 write paths to real persistence |
| 3 | `phase-3-read-paths.md` | Replace mocks with real reads |
| 4 | `phase-4-realtime-and-triggers.md` | Add realtime, triggers, side effects, audit |
| 5 | `phase-5-polish.md` | P1/P2 polish — accessibility, performance, copy |
| 6 | `phase-6-release-gate.md` | The release gate — sign-off, evidence, go-live |

You can rename, reorder, add, or remove phases. Update `canonical_prompt.md` §PHASE PIPELINE in lockstep.

## How Conductor Uses This

```
canonical_prompt.md  → declares the phase order
Conductor reads pipeline-state.json  → picks ACTIVE_PHASE
Conductor opens phases/phase-<N>-*.md  → that's the only phase file in context
Roles execute that phase's STEPS  → write evidence to session JSONL
Conductor verifies EXIT CRITERIA  → flips state to GREEN, advances
```

A phase file is the single in-context phase document. Other phase files are NOT read in the same session — that keeps prompts tight and prevents cross-phase leakage.

## Editing a Phase

When you change a phase's exit criteria or roster, also update:

1. `canonical_prompt.md` if the phase's role in the pipeline changed.
2. `business/ROUTING.md` if the roster references new roles.
3. `release-readiness-intelligence/go-live-gate-taxonomy.md` (when present) if gate letters changed.

Per `business/FRAME_CONTROL_ALGORITHM.md` orphan-prevention rule, every phase file must be referenced from `canonical_prompt.md`.

## Cross-References

Referenced from: `canonical_prompt.md` §PHASE PIPELINE, `CONDUCTOR.md` §SESSION LIFECYCLE, `conductor/README.md` (orchestration flow).

References: `business/ROUTING.md`, `business/{domain}-intelligence/`, `business/roles/`.
