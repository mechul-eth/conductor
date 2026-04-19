# orchestrator/prompts/ — Per-Task Prompt Bodies (optional)

> If you want to pre-author task prompts (instead of relying on `tasks.json` `description` synthesis), drop them here as `task_<id>.md` (e.g. `task_2_1.md` for task `2.1`). The dispatch envelope picks them up automatically.

## When to Use

- **Skip this directory entirely** for ad-hoc or short pipelines — `dispatch.sh` synthesizes a body from `tasks.json`'s `description` field, which is enough for most tasks.
- **Use this directory** when a task needs a long, structured body — multi-section context, embedded code snippets, source-of-truth excerpts. Hand-author a `task_<id>.md` here.

## File Naming

The file name is derived from the task ID by replacing `.` with `_`:

| Task ID | File name |
|---------|-----------|
| `1.1`   | `task_1_1.md` |
| `2.3`   | `task_2_3.md` |
| `phase-0-preflight` | `task_phase-0-preflight.md` |

## Content Format

Free-form markdown. The dispatch envelope wraps it as section 4 (TASK BODY).
Keep it focused — every line costs on every retry.

Suggested structure:

```markdown
## Goal
{one paragraph}

## Context (load before doing anything)
- {file path 1}
- {file path 2}

## Steps
1. {step}
2. {step}

## Out of scope
- {explicit skip}
```

## Cross-References

- Read by `orchestrator/lib/dispatch.sh::dispatch_to_role` (looks for `task_<id>.md`)
- Falls back to `tasks.json` `description` field if no file exists
