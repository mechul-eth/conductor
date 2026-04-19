## What does this PR do?

<!-- Brief description of the change -->

## Which component(s) does it touch?

- [ ] `CONDUCTOR.md` (brain / routing policy)
- [ ] `conductor/` (mode triggers, orchestration flow)
- [ ] `registry/` / `identity/` / `graph/` / `map/` / `optimizer/` / `governance/` / `profiles/` / `session/`
- [ ] `activation/` (incl. VS Code + other IDE kits)
- [ ] `business/` (ROUTING, FRAME_CONTROL, roles/, intelligence domains, segments, research)
- [ ] `phases/` / `canonical_prompt.md`
- [ ] `orchestrator/` (runtime — conductor.sh, lib/, roles/, gates/)
- [ ] `.github/` (CI, templates)
- [ ] Top-level docs (README, CONTRIBUTING, CHANGELOG, CODE_OF_CONDUCT, SECURITY)

## Checklist

- [ ] Changes are limited to `conductor-core/`, `orchestrator/`, or root docs — Layer 1 (`agency-agents/`, `gstack/`, `promptfoo/`) is read-only
- [ ] No hardcoded paths or machine-specific values
- [ ] Orphan-prevention check passes per `conductor-core/business/FRAME_CONTROL_ALGORITHM.md` (every new artifact is referenced from a README, `ROUTING.md`, and a gate)
- [ ] `shellcheck` clean on any bash scripts touched (orchestrator/conductor.sh, lib/*.sh)
- [ ] Any new JSON files validate with `jq empty <file>`
- [ ] CHANGELOG.md updated (if user-facing change)

## Context

<!-- Why is this change needed? Link to issue if applicable. -->
