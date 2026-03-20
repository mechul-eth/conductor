# Graph — Always-On Semantic Code Graph

> Every agent reasons about the codebase as connected intelligence — not filenames plus grep. The graph initializes silently on every session and provides workspace context to all roles automatically.

## Design Advisors (Layer 1 — do not rebuild)
- `agency-agents/specialized/lsp-index-engineer.md` — graphd architecture, LSP 3.17 compliance, sub-500ms targets, WebSocket streaming, 100k symbol scale
- `agency-agents/specialized/zk-steward.md` — Luhmann 4-principle knowledge validation

## Core Guarantees

1. **Always on.** Graph initializes automatically on every session with workspace context. No user invocation required.
2. **Non-blocking.** Initialization never blocks the first user prompt. If it takes time, the first prompt runs with file-based context while the graph catches up.
3. **Fail-safe.** If initialization fails, fall back to file-based context. The failure is **recorded in session state** (`graph_status: degraded, reason: <error>`) — so it is not a silent failure in the `zero_silent_failures` prime directive sense. The degradation is not surfaced as a blocking error to the user (graceful UX), but it is observable via session state on request.
4. **Connected intelligence.** Every query returns relationships between symbols, not just file locations. "Who calls this function?" not "Which file contains this string?"
5. **Privacy in traces.** OTel spans contain span names and durations only — no code content, symbol names, or file paths in span metadata.

## Initialization Sequence

```
Session start
  → graph/ scans workspace structure
  → Build symbol table: functions, classes, types, exports, imports
  → Build relationship edges: calls, imports, extends, implements, uses
  → Build file dependency tree
  → Apply Luhmann 4-principle validation to each knowledge node:
      1. Atomicity — can this fact be understood standalone?
      2. Connectivity — does it link to ≥2 other facts in the graph?
      3. Organic growth — does it avoid over-taxonomization?
      4. Continued dialogue — does it surface context for other agents?
  → Nodes failing validation get UNVALIDATED flag (stored, but not trusted for routing decisions)
  → Index entries are entry points, not categories — one node can have multiple index entries
  → Write initialization status to session/ state
  → READY (or DEGRADED if partial)
```

## Query Interface

```yaml
graph_query:
  type: <symbol_lookup | relationship | dependency_tree | impact_analysis | search>
  target: <symbol name, file path, or search term>
  depth: <1-N hops from target>
  filters:
    domain: <optional domain filter>
    file_pattern: <optional glob>
    relationship_type: <calls | imports | extends | implements | uses>
```

### Query Types

| Type | Returns | Example |
|------|---------|---------|
| `symbol_lookup` | Symbol definition + metadata | "Where is `AuthService` defined?" |
| `relationship` | Connected symbols within N hops | "What does `AuthService` call?" |
| `dependency_tree` | Import/export chain | "What depends on `src/auth/`?" |
| `impact_analysis` | All files affected by changing a symbol | "If I change `validateToken`, what breaks?" |
| `search` | Semantic search across graph nodes | "Find all authentication-related code" |

### Performance Targets (from LSP/Index Engineer spec)

| Metric | Target |
|--------|--------|
| Symbol lookup | < 100ms |
| Relationship query (depth 1) | < 200ms |
| Dependency tree | < 500ms |
| Impact analysis | < 500ms |
| Full graph initialization (< 10k files) | < 10s |
| Full graph initialization (< 100k symbols) | < 30s |

## Knowledge Node Schema

```yaml
node:
  id: <deterministic hash of file_path + symbol_name + symbol_type>
  symbol_name: <name>
  symbol_type: <function | class | type | variable | export | import | module>
  file_path: <relative path from workspace root>
  line_range: [<start>, <end>]
  relationships:
    calls: [<node_ids>]
    called_by: [<node_ids>]
    imports: [<node_ids>]
    imported_by: [<node_ids>]
    extends: [<node_ids>]
    implements: [<node_ids>]
  validation_status: <VALIDATED | UNVALIDATED>
  luhmann_scores:
    atomicity: <bool>
    connectivity: <bool — true if ≥2 relationships>
    organic_growth: <bool — true if not over-categorized>
    continued_dialogue: <bool — true if surfaces context for other agents>
  index_entries: [<topic tags — entry points, not categories>]
  last_updated: <ISO-8601>
```

## OTel Tracing (Promptfoo Wiring)

graph/ emits OpenTelemetry spans for every initialization, query, and update event:

```
Span format: W3C traceparent
  version: 00
  traceId: <16-byte random hex>
  spanId: <8-byte random hex>
  traceFlags: 01 (sampled)

Emitted spans:
  - graph.init (initialization duration)
  - graph.query.<type> (per-query latency)
  - graph.update (incremental update on file change)

Collected by: promptfoo tracing/otlpReceiver.ts at 127.0.0.1:4318
Read by: optimizer/ to detect slow queries and reroute if above 2x threshold
```

**Privacy rule:** Spans contain `{span_name, duration_ms, status_code}` only. No code content, no symbol names, no file paths.

## Trace Assertions (validate graph behavior)

| Assertion | What It Checks |
|-----------|----------------|
| `trace-span-count` | Expected number of graph spans exist per session |
| `trace-span-duration` | No graph query exceeds 2x the performance target |
| `trace-error-spans` | Error span count stays within threshold |

## Degraded Mode

When graph initialization fails:

| Feature | Full Mode | Degraded Mode |
|---------|-----------|---------------|
| Symbol lookup | Graph query | `grep` + file path |
| Relationship queries | Connected graph | Not available |
| Impact analysis | Full dependency tree | File-level only (imports) |
| Search | Semantic across graph | Text search only |

Session state records: `graph_status: degraded, reason: <error>, fallback: file-based`

## Integration Points

| Component | How graph/ interacts |
|-----------|---------------------|
| `session/` | Graph status written to session state; queries carry session context |
| `map/` | map/ queries graph for codebase context before generating opening prompts |
| `identity/` | Graph queries carry agent_id for audit trail |
| `optimizer/` | Optimizer reads graph trace spans to detect latency spikes |
| All roles | Every role can query the graph for connected-intelligence context instead of file grep |
