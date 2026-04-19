# orchestrator/gates/ — Per-Task Custom Gate Scripts

> `lib/gates.sh` provides default gate implementations. When a specific task needs a different check, drop a script here and the runtime will use it instead.

## File Naming

`{GATE_LETTER}_{task_id_with_underscores}.sh`

Examples:

| Gate + task | File |
|-------------|------|
| `C_test` for task `2.1` | `C_2_1.sh` |
| `A_topology` for task `1.1` | `A_1_1.sh` |
| `D_e2e` for task `4.1` | `D_4_1.sh` |

## Contract

- Receives the task JSON as `$1`
- Returns `0` for PASS, non-zero for FAIL
- Writes evidence to stdout + the main log file (uses `log_info` / `log_error` via sourced `lib/log.sh`)

## Example

```bash
#!/usr/bin/env bash
# gates/C_2_1.sh — custom test gate for task 2.1

set -euo pipefail

task_json="${1:-}"

cd "${REPO_ROOT}/api"
if npm test -- --testPathPattern="checkout" --silent; then
  echo "Task 2.1 checkout tests passed"
  exit 0
else
  echo "Task 2.1 checkout tests FAILED"
  exit 1
fi
```

## When Custom Gates Are Better Than `tasks.json` Gates

Use a custom gate when:

- The check needs to hit a real URL, DB, or API
- The check is task-specific and too detailed for `tasks.json`
- You want evidence logs captured in a specific format

Otherwise, stick with the default gates from `lib/gates.sh` — they handle the common cases (typecheck, test suite, credential scan, acceptance criteria).

## Cross-References

- Called by `orchestrator/lib/gates.sh::gate_run`
- Task-specific gate letters come from the `gates` array in `tasks.json`
