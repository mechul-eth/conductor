# Conductor — Unified Entry Point

> One entry. Every mode. Every IDE. The conductor reads the user's intent, activates the right components, routes to the right roles, and ensures the session closes clean.

## Design Advisors (Layer 1 — do not rebuild)
- `gstack/conductor.json` — gstack's orchestration config pattern
- `agency-agents/strategy/nexus-strategy.md` — NEXUS multi-agent composition
- `agency-agents/strategy/playbooks/` — phase-based playbook sequencing
- `agency-agents/strategy/runbooks/` — scenario-specific execution patterns

## Core Guarantees

1. **Single entry point.** All MG_MODE interactions start through conductor/.
2. **Mode-aware.** Supports plan, ask, execute, and review modes — routes differently for each.
3. **Component orchestration.** Calls each component in the correct order. No component runs without conductor/ initiating it.
4. **Loop safety.** Enforces max retries, escalation, and stop conditions globally.
5. **Clean close.** Every session ends with a proper close — state saved, costs logged, handoff written.

---

## Orchestration Flow

```
USER INPUT
    │
    ▼
┌─────────────────────────────────────────────────────┐
│  CONDUCTOR                                           │
│                                                      │
│  1. Parse intent                                     │
│     → Classify mode: plan | ask | execute | review   │
│     → Extract: what, why, constraints                │
│                                                      │
│  2. Check session state (session/)                   │
│     → First run? → Trigger activation/               │
│       → Existing codebase? → Run business/ auto-scan │
│       → Fresh project? → Run business/ onboarding Qs │
│     → Existing session? → Load context               │
│     → Budget remaining? → Check optimizer/            │
│                                                      │
│  3. Pre-execution (map/)                             │
│     → Gather context from graph/ + session/ + business│
│     → Select roles from registry/                    │
│     → Generate opening prompt with synthesis          │
│     → Run governance/ gate if profile requires it     │
│                                                      │
│  4. Identity check (identity/)                       │
│     → Validate selected roles' authority scope       │
│     → Issue agent tokens for this task               │
│                                                      │
│  5. Execute                                          │
│     → Route to selected roles                        │
│     → Monitor for scope drift (map/)                 │
│     → Track cost (optimizer/)                        │
│     → Enforce loop safety                            │
│                                                      │
│  6. Post-execution (map/)                            │
│     → Check scope drift                              │
│     → Build handoff schema                           │
│     → Recommend next prompt                          │
│                                                      │
│  7. Quality gate                                     │
│     → Run promptfoo assertions (per profile)         │
│     → Validate completion status                     │
│                                                      │
│  8. Persist (session/)                               │
│     → Save task result to session state              │
│     → Update cost summary                            │
│     → Write handoff if multi-step                    │
│                                                      │
│  9. Respond to user                                  │
│     → Deliver result with completion status           │
│     → Surface concerns if DONE_WITH_CONCERNS         │
│     → Ask questions if NEEDS_CONTEXT                 │
│     → Escalate if BLOCKED or INCIDENT                │
└─────────────────────────────────────────────────────┘
```

---

## Role Transition Format

Every time the conductor activates a role or switches from one role to another, it **MUST** emit a role announcement block in the chat. This is a non-optional UX requirement. It gives the user live visibility into which specialist is currently working on their request.

### Format — Single Role (first activation or solo task)

```
> ◈ `<role-slug>` · <Domain>
> <one-line description of what this role is doing right now>
```

**Example:**
```
> ◈ `engineering-software-architect` · Engineering
> Designing component boundaries and API contracts
```

### Format — Role Swap (mid-task handoff between roles)

```
> ◈ Handoff → `<next-role-slug>` · <Domain>
> <one-line description of what the next role picks up>
```

**Example:**
```
> ◈ Handoff → `engineering-code-reviewer` · Engineering
> Reviewing implementation against acceptance criteria
```

### Format — Multi-Role Session Opener (when ≥ 2 roles are selected upfront)

When map/ selects multiple roles before execution begins, emit this summary block once before the first role activates:

```
> ◈ **<N> roles for this task**
> 1. `<role-slug-1>` — <one-line purpose>
> 2. `<role-slug-2>` — <one-line purpose>
> 3. `<role-slug-3>` — <one-line purpose>
```

**Example:**
```
> ◈ **3 roles for this task**
> 1. `engineering-software-architect` — system design
> 2. `engineering-software-engineer` — implementation
> 3. `engineering-code-reviewer` — quality gate
```

Then emit a single-role block as each role activates in sequence.

### Rules

1. **Always emit before the role's first output.** The block must appear immediately before the role begins its work, not after.
2. **Role slug must match the filename in `agency-agents/`.** No custom names, no abbreviations.
3. **Domain must match the role's top-level folder in `agency-agents/`.** (e.g. `Engineering`, `Design`, `Product`, `Strategy`, `Marketing`, `Sales`, `Testing`, `Support`, `Project Management`, `Spatial Computing`, `Academic`, `Game Development`, `Specialized`).
4. **One-line task description must be plain language.** Describe what the role is actually doing in this specific task, not its generic purpose.
5. **Session opener is optional when only 1 role is involved.** Emit only the single-role block in that case.
6. **No block for internal utility calls.** Don't emit a block when conductor/ is querying `session/`, `graph/`, or `optimizer/` internally. Only emit when a named role from `agency-agents/` is activated.

---

## Mode Routing

Single source of truth: `mode-triggers.json`

Matching contract:
- Normalize the incoming request to lowercase and trim surrounding whitespace.
- Match substring phrases against the trigger registry in `mode-triggers.json`.
- If exactly one mode matches, route to that mode.
- If zero or multiple modes match, ask a clarifying question instead of guessing.

### Plan Mode
```
Registry keywords: "plan", "design", "architect", "think about", "how should we"

Conductor routes to:
  → map/ in plan mode (12 design cognitive patterns)
  → Relevant planning skills: office-hours, plan-ceo-review, plan-eng-review, plan-design-review
  → Output: ADR, design doc, or plan document
  → Does NOT execute code. Planning only.

Roles typically involved:
  → engineering-software-architect, product-manager, design-ux-architect
  → Plus domain-specific roles based on intent
```

### Ask Mode
```
Registry keywords: "what is", "explain", "why does", "how does", "show me"

Conductor routes to:
  → graph/ for code intelligence lookup
  → investigate skill for deep code questions
  → Relevant domain expert role
  → Output: Explanation, not code changes

Roles typically involved:
  → engineering-senior-developer (code questions)
  → Domain expert based on question topic
  → No file modifications in ask mode
```

### Execute Mode
```
Registry keywords: "build", "create", "fix", "implement", "add", "remove", "update"

Conductor routes to:
  → Full orchestration flow (steps 1-9 above)
  → map/ pre-execution → role selection → execution → quality gate
  → Output: Code changes, file modifications, deliverables

Action classification before execution:
  → blast_radius ≤ 5 files AND reversible → AUTO-APPLY
  → blast_radius > 5 files OR irreversible → SURFACE-TO-USER (show plan, wait for approval)
```

### Review Mode
```
Registry keywords: "review", "check", "audit", "validate", "test"

Conductor routes to:
  → review skill (code review)
  → guard skill (security + quality)
  → qa skill (browser-based testing)
  → Relevant testing roles
  → Output: Review findings, fixes applied or suggested

Roles typically involved:
  → engineering-code-reviewer, testing-reality-checker
  → engineering-security-engineer (if security review)
  → testing-accessibility-auditor (if a11y review)
```

---

## Loop Safety (Global Enforcement)

```yaml
loop_safety:
  max_retries: 3
  
  # Retry gating
  on_retry:
    - Check: is this the same error as last attempt?
    - If yes: escalate (don't retry same thing)
    - If no: allow retry with different approach
  
  # Semantic similarity check
  similarity_threshold: 0.85
  # If two consecutive outputs are >85% similar, the loop is stuck
  on_stuck:
    - Checkpoint current state
    - Surface to user: "I'm going in circles. Here's what I've tried: [list]. What should I change?"
  
  # Hard stop
  on_max_retries_exceeded:
    - Save state to session/
    - Mark task as BLOCKED
    - Write handoff with: what was tried, what failed, recommended next step
    - Return to user with clear status
  
  # Protected patterns (never retry)
  no_retry:
    - Database migrations
    - Destructive file operations (rm -rf, DROP TABLE)
    - Published git operations (push --force)
    - Infrastructure changes (terraform apply)
```

---

## Escalation Protocol

```
Level 0 — AUTO (conductor handles silently)
  Small scope, reversible, within budget, within authority
  
Level 1 — SURFACE (show user, ask for approval)
  Large scope, high blast radius, or first-time pattern
  
Level 2 — BLOCK (stop and wait)
  Budget exceeded, authority insufficient, governance gate failed
  
Level 3 — INCIDENT (emergency stop)
  Security violation, data integrity risk, production impact
```

---

## Component Call Order

The exact order conductor/ calls components for a standard execute task:

```
1. session/     → load or initialize session state
2. activation/  → (first run only) bootstrap environment
3. profiles/    → (first run only) run onboarding questions
4. business/    → (first run) initialize directory + run 3-question onboarding
                  (subsequent runs) load business context for current task
5. graph/       → ensure graph is initialized
6. map/         → pre-execution: gather context (session/ + business/ + graph/), select roles, generate prompt
7. registry/    → validate selected roles exist and have required capabilities
8. governance/  → (if profile requires) run 3-question gate
9. identity/    → issue tokens, validate authority
10. optimizer/  → check budget, select cost posture
11. [EXECUTE]   → emit role transition block(s) per "Role Transition Format" spec
                  → route to roles, monitor drift
12. map/        → post-execution: check drift, build handoff
13. promptfoo/  → (per profile) run validation assertions
14. session/    → persist results, update cost summary
15. optimizer/  → record cost, check circuit breaker
16. conductor/  → format response, deliver to user
```

---

## First Run Detection

```
Conductor checks for session state:
  
  If ~/.mg-mode/sessions/ does not exist:
    → This is a first-ever run
    → Trigger activation/ bootstrap
    → Then profiles/ onboarding
    → Then session/ initialization
    → Then proceed with task
  
  If session state exists but no active session:
    → New session, existing user
    → Load profile from ~/.mg-mode/projects/$SLUG/profile.yaml
    → Initialize new session state
    → Proceed with task
  
  If active session exists:
    → Continuing session
    → Load session state
    → Resume from last checkpoint
    → Proceed with task
```

---

## Handoff Between Sessions

When a session ends mid-work:

```yaml
# Written to session state as the final entry
handoff:
  session_id: <current session>
  completed_tasks: [<task IDs done>]
  in_progress_task:
    task_id: <task ID>
    status: <where it stopped>
    last_action: <what was the last thing done>
    next_action: <what should happen next>
  open_items:
    blocked: [<items blocked>]
    deferred: [<items in TODOS.md>]
    questions: [<open questions for user>]
  recommended_next_prompt: |
    <suggested prompt for continuing in next session>
  
  # Prime directives check
  prime_directives:
    budget_status: <remaining / exceeded>
    security_flags: <any security concerns>
    scope_drift: <CLEAN / SCOPE_CREEP / REQUIREMENTS_MISSING>
```

---

## Error Handling

```
On component failure:
  1. Log the failure to session state
  2. Check if the component has a degraded mode (see graph/, optimizer/)
  3. If degraded mode exists: continue with reduced capability
  4. If no degraded mode: mark task as BLOCKED, surface to user
  5. Never silently swallow errors

On model failure (API error, timeout):
  1. optimizer/ circuit breaker evaluates
  2. If budget allows: retry with backoff
  3. If budget exhausted: switch to cheaper model
  4. If all models fail: BLOCKED with clear error message

On role unavailable:
  1. registry/ provides fallback role
  2. If fallback exists: use fallback, note in handoff
  3. If no fallback: BLOCKED, surface missing capability to user
```

---

## Completion Status Delivery

Every conductor/ response includes a completion status:

| Status | Meaning | User Action |
|--------|---------|-------------|
| `DONE` | Task complete, no concerns | None needed |
| `DONE_WITH_CONCERNS` | Task complete, but concerns exist | Review concerns before proceeding |
| `BLOCKED` | Cannot proceed without user input | Resolve blocker, then re-run |
| `NEEDS_CONTEXT` | Missing information to proceed | Provide requested context |
| `INCIDENT` | Security or integrity issue detected | Immediate attention required |

---

## Integration Points

| Component | How conductor/ interacts |
|-----------|--------------------------|
| `MG_MODE.md` | conductor/ enforces all policies defined in the brain file |
| `session/` | conductor/ reads/writes session state at start and end of every task |
| `activation/` | conductor/ triggers activation/ on first run |
| `profiles/` | conductor/ loads profile config for every decision |
| `business/` | conductor/ initializes business/ on first run; map/ loads business context on every task |
| `graph/` | conductor/ ensures graph is available before routing |
| `map/` | conductor/ delegates pre/during/post execution to map/ |
| `registry/` | conductor/ validates role selections against registry/ |
| `governance/` | conductor/ runs governance gate when profile requires it |
| `identity/` | conductor/ requests identity tokens for each task |
| `optimizer/` | conductor/ checks budget and records cost for every task |
| `promptfoo/` | conductor/ triggers validation assertions per profile config |
