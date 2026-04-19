# START HERE — Orchestrator Setup

> You only need this if you want the bash runtime. For IDE-only use, see `conductor-core/activation/README.md`.

## Prerequisites

- Bash 4+ (macOS has 3.2 by default — install via Homebrew: `brew install bash`)
- `jq` (`brew install jq` / `apt install jq`)
- `flock` (optional; used for file locks — falls back to `mkdir`-mutex if absent)
- Either an IDE with a Claude Code-compatible agent (for `parent_agent` dispatch mode), OR the `claude` CLI (for `cli` dispatch mode)

## One-time Setup

```bash
# 1. Make the entrypoint executable
chmod +x orchestrator/conductor.sh

# 2. Copy the task queue template and edit it
cp orchestrator/tasks.example.json orchestrator/tasks.json

# 3. Edit tasks.json to list your actual tasks (or generate it from conductor-core/phases/)

# 4. Run preflight to confirm the environment is healthy
./orchestrator/conductor.sh preflight
```

## Daily Use

```bash
./orchestrator/conductor.sh status    # see where the pipeline is
./orchestrator/conductor.sh resume    # continue from last checkpoint (safe to call anywhere)
./orchestrator/conductor.sh halt      # stop the loop cleanly (HALT checkpoint written)
./orchestrator/conductor.sh reset <id>   # admin — reset a task to PENDING
```

## First-Time Kickoff

```bash
./orchestrator/conductor.sh start     # creates state.jsonl and runs the first task
```

## Unattended Runs (optional)

For long pipelines where you hit token limits, register the scheduled resumer:

```bash
# Add to crontab — runs every 30 minutes, no-ops if another instance is alive
*/30 * * * * cd /path/to/repo && ./orchestrator/conductor.sh resume >> orchestrator/logs/cron.log 2>&1
```

The master lock ensures only one conductor runs at a time.

## Dispatch Mode

By default the orchestrator auto-detects:
- If an interactive IDE agent is handling markers → `parent_agent` mode
- Otherwise, if the `claude` CLI is installed → `cli` mode

Force a specific mode:

```bash
CONDUCTOR_DISPATCH_MODE=cli ./orchestrator/conductor.sh resume
CONDUCTOR_DISPATCH_MODE=parent_agent ./orchestrator/conductor.sh resume
```

## Troubleshooting

**"Another orchestrator is running."**
Master lock held by a live pid. Run `./conductor.sh status` to see the owner. If the owner died, the lock auto-breaks after 30 minutes; or `rm orchestrator/locks/master.lock` to force-release (only if you're sure).

**"state.jsonl malformed."**
```bash
./orchestrator/conductor.sh validate-state
# If corrupt: restore from orchestrator/state.jsonl.bak (every write is backed up)
```

**"Task stuck in BLOCKED forever."**
Check `orchestrator/blockers/<task>.md` for the role's explanation. Consensus rounds write their findings there. Once resolved, `reset <task_id>` and `resume`.
