# Claude Code — Conductor Activation

> Claude Code is the first-class agent for Conductor when you want unattended multi-phase pipelines. It reads project-level instructions from `CLAUDE.md` and `AGENTS.md` automatically.

## Setup

```bash
# Copy the instruction template to the repo root
cp conductor-core/activation/claude-code/CLAUDE.md CLAUDE.md
# (Optional) Add the orchestrator runtime trigger
cp conductor-core/activation/claude-code/AGENTS.md AGENTS.md
```

Both files live at the repo root so Claude Code picks them up on every session.

## First Session

Start Claude Code in the repo root. Say:

> Activate Conductor

Claude Code reads `CLAUDE.md` → follows `conductor-core/activation/FIRST_RUN.md` → onboarding flow begins.

## Unattended Pipeline

If you want Claude Code to run a pipeline overnight (or wake via cron when token limits reset), use the orchestrator runtime:

```bash
./orchestrator/conductor.sh start     # first-time kickoff
./orchestrator/conductor.sh resume    # pick up from last checkpoint
./orchestrator/conductor.sh status    # show state
```

The runtime dispatches tasks to subagents via the Task tool or `claude --print` (see `orchestrator/README.md`).

## Cross-References

Referenced from `conductor-core/activation/README.md` and the top-level `README.md` Quick Start.
