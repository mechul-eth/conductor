# Optimizer — Autonomous Cost and Routing Circuit Breaker

> Shadow-tests model API calls, routes traffic to better or cheaper models, and enforces financial and security circuit breakers. Passive by default: reports savings, blocks overruns, reroutes before degradation is visible.

## Design Advisors (Layer 1 — do not rebuild)
- `promptfoo/src/scheduler/adaptiveConcurrency.ts` — concurrency control contracts
- `promptfoo/src/scheduler/retryPolicy.ts` — backoff strategy contracts
- `agency-agents/engineering/engineering-autonomous-optimization-architect.md` — dark-launch methodology

## Core Guarantees

1. **Budget enforcement.** No session exceeds its profile budget cap. Hard stop at 100% for all profiles except `learning`, which uses soft enforcement (suggestion only — no automatic halt).
2. **Latency monitoring.** Reroute to cheaper model when latency exceeds 2x expected.
3. **Shadow testing.** 5% of model API calls silently routed to challenger model for comparison.
4. **Circuit breaker.** Trip immediately on: budget exhaustion, 500% traffic spike, repeated 402/429 errors.
5. **Cost-first ordering.** Cheaper validations always run before expensive ones.

---

## Budget Thresholds

| Threshold | Action |
|-----------|--------|
| 70% consumed | Warn user: "Budget at 70% — N remaining at current rate" |
| 90% consumed | Alert: "Budget critical — consider switching to cheaper model" |
| 100% consumed | **Hard stop.** Scheduler paused (not individual calls rejected). User must confirm to continue or adjust budget. |

### Profile Budget Caps

| Profile | Cap | Enforcement |
|---------|-----|-------------|
| learning | Low ($5/session default) | Soft warning at 70%, suggestion at 100% |
| MVP | Medium ($25/session default) | Hard warning at 70%, hard stop at 100% |
| production-lite | Higher ($100/session default) | Alerts at 70%, hard stop at 100% |
| production-strict | Enforced ($500/session default) | Automatic stop at 100%, no override without governance approval |

Caps are configurable at profile setup. Defaults above are starting points.

---

## Scheduler Contracts (from promptfoo)

optimizer/ adopts these contracts as its execution backbone. Does not reimplement them.

### AdaptiveConcurrency
```
On rate-limit (HTTP 429):
  → Halve concurrency immediately
  → Wait for Retry-After header duration (if provided)

On success streak (5 consecutive):
  → Increase concurrency by 50%
  → Cap at initial maximum

Recovery is gradual, degradation is immediate.
```

### RetryPolicy
```
Strategy: exponential backoff with jitter
Base delay: 1 second
Max delay: 60 seconds
Max retries: 3
Jitter: random 0-50% of computed delay

Retry-After header: honored when server provides it (overrides computed delay)
Non-retryable errors: 400, 401, 403 → fail immediately, no retry
Retryable errors: 408, 429, 500, 502, 503, 504 → retry with backoff
```

### RateLimitRegistry
```
Per-provider slot queues:
  Each model provider has its own concurrency pool
  Requests queue when pool is full
  FIFO ordering within each queue
```

### Budget Circuit Breaker
```
Sits ABOVE the scheduler layer:
  When profile cap reached → pause the entire scheduler
  Individual calls are not rejected — the pipeline pauses
  User notification: "Budget cap reached. Approve additional $X or switch to cheaper model?"
  On approval → resume scheduler with updated cap
```

---

## Shadow Testing (Dark-Launch)

5% of model API calls are silently shadow-routed to a challenger model:

```
1. SELECT — Pick 1 in 20 API calls at random for shadow testing
2. FORK — Send the same prompt to both primary and challenger model
3. SCORE — LLM-as-Judge grades both responses using pre-established criteria:
   - N points for correct output format
   - N points for factual accuracy
   - N points for latency (within threshold)
   - -10 points for detected hallucination
   Criteria are set BEFORE the shadow test begins and stored in session record
4. COMPARE — Track challenger vs. primary performance over time
5. RECOMMEND — When challenger proves equal quality at lower cost over
   statistically significant sample:
   → Surface routing recommendation to user
   → NEVER auto-promote without explicit user confirmation
     (exception: learning profile may opt-in to auto-promotion)
```

### Circuit Breaker Extensions

| Trigger | Action |
|---------|--------|
| 500% traffic spike | Trip immediately → route to cheapest fallback → alert user (possible bot attack) |
| Repeated HTTP 402 | Payment issue → pause all calls → alert user |
| Repeated HTTP 429 | Rate limit → halve concurrency → wait for backoff |
| Challenger outperforms primary 10+ times | Surface model switch recommendation |

---

## Cost Tracking

Every model API call records:

```jsonl
{"session_id":"sess_001","agent_id":"abc123","provider":"anthropic","model":"claude-sonnet-4-20250514","tokens_in":1500,"tokens_out":500,"cost_usd":0.0045,"latency_ms":1200,"timestamp":"2026-03-20T12:00:00Z","shadow":false}
{"session_id":"sess_001","agent_id":"abc123","provider":"openai","model":"gpt-4o-mini","tokens_in":1500,"tokens_out":480,"cost_usd":0.0008,"latency_ms":800,"timestamp":"2026-03-20T12:00:01Z","shadow":true}
```

### Session Summary (written on session close)

```yaml
cost_summary:
  session_id: <id>
  profile: <learning|MVP|production-lite|production-strict>
  budget_cap: <cap in USD>
  total_cost: <actual spend>
  budget_remaining: <cap - spend>
  calls_made: <count>
  shadow_tests: <count>
  primary_model: <most-used model>
  avg_latency_ms: <average>
  reroutes: <count of latency-based reroutes>
  circuit_breaker_trips: <count>
  challenger_wins: <count where challenger beat primary>
  recommendation: <null | "Consider switching to X — saved $Y in shadow tests">
```

---

## Cost Ordering for Validation

Always run cheaper checks first:

| Order | Check Type | Typical Cost |
|-------|-----------|-------------|
| 1 | Structure (is-json, regex, contains) | $0 (local) |
| 2 | Latency/cost assertions | $0 (local) |
| 3 | llm-rubric | $ (1 LLM call) |
| 4 | g-eval / factuality | $$ (multi-criteria LLM) |
| 5 | Redteam plugins | $$$ (multiple attack vectors) |
| 6 | Multi-turn simulation | $$$$ (N-turn conversation) |

Short-circuit: if step 1 or 2 fails, skip steps 3-6 (no point running expensive checks on structurally invalid output).

---

## Integration Points

| Component | How optimizer/ interacts |
|-----------|------------------------|
| `session/` | Reads budget cap from profile; writes cost summary on close |
| `profiles/` | Profile determines budget cap and which validations to run |
| `graph/` | Reads graph trace spans to detect slow queries |
| `identity/` | Model calls carry agent_id for per-agent cost attribution |
| `governance/` | Budget override at production-strict requires governance approval |
| `map/` | map/ respects budget constraints in opening prompt generation |
