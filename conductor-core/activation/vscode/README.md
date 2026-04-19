# VS Code — First-Class Conductor Activation

> One-time setup for VS Code + GitHub Copilot Chat. After this, Copilot Chat acts as your Conductor entry point — you say things like "Activate Conductor" or "Plan the onboarding flow" and the agent follows the runbook.

## What This Gives You

- Copilot Chat reads a project instruction file at `.github/copilot-instructions.md` on every session — it loads `CONDUCTOR.md` + activation runbook automatically.
- A `.vscode/` folder with tasks, settings, and extension recommendations.
- An MCP config stub you can extend when you add external context sources.
- Keyboard-shortcut hints for the common Conductor commands (Plan / Ask / Execute / Review).

## Setup

### 1. Copy the kit into your project

```bash
# From the repo root:
mkdir -p .github .vscode
cp conductor-core/activation/vscode/copilot-instructions.md .github/copilot-instructions.md
cp conductor-core/activation/vscode/settings.json .vscode/settings.json
cp conductor-core/activation/vscode/extensions.json .vscode/extensions.json
cp conductor-core/activation/vscode/tasks.json .vscode/tasks.json
cp conductor-core/activation/vscode/mcp.example.json .vscode/mcp.json
```

You don't have to use all four — Copilot-instructions is the only required file. The rest are quality-of-life.

### 2. Install the recommended extensions

Open VS Code → the recommendations banner shows the Copilot Chat extension and a few helpers. Click "Install All." Minimum: GitHub Copilot + GitHub Copilot Chat.

### 3. First session

Open Copilot Chat (⌃⌘I on macOS, Ctrl+Alt+I on Windows/Linux). Type:

> Activate Conductor

Copilot Chat will read `.github/copilot-instructions.md` + the Conductor runbook and walk you through the First Run flow (`conductor-core/activation/FIRST_RUN.md`).

---

## Files in this Kit

| File | Purpose | Required? |
|------|---------|-----------|
| `copilot-instructions.md` | Project-level instructions Copilot reads on every session — points it at `CONDUCTOR.md` + the runbook | Yes |
| `settings.json` | VS Code workspace settings tuned for Conductor workflow (Copilot defaults, format-on-save, file associations) | Recommended |
| `extensions.json` | Extension recommendations (Copilot + Copilot Chat minimum) | Recommended |
| `tasks.json` | Workspace tasks for running the orchestrator runtime + common checks | Optional |
| `mcp.example.json` | Stub MCP server config — rename to `mcp.json` and fill in your connections | Optional |

## Keyboard Shortcuts

Add these to `keybindings.json` for quick mode-switching in Copilot Chat:

```json
[
  { "key": "cmd+shift+p", "command": "github.copilot.chat.open", "args": "Plan: " },
  { "key": "cmd+shift+a", "command": "github.copilot.chat.open", "args": "Ask: " },
  { "key": "cmd+shift+e", "command": "github.copilot.chat.open", "args": "Execute: " },
  { "key": "cmd+shift+r", "command": "github.copilot.chat.open", "args": "Review: " }
]
```

These match the four modes in `conductor/mode-triggers.json` — Conductor picks them up automatically.

## Troubleshooting

**"Copilot Chat is suggesting things before I ask."**
Turn off proactive suggestions: `gstack-config set proactive false` (per `CONDUCTOR.md` §SUPREME POLICY).

**"Copilot doesn't seem to know about CONDUCTOR.md."**
Verify `.github/copilot-instructions.md` is in place. Reload the VS Code window. Open the file in the editor briefly — Copilot will re-read.

**"I want to switch to Claude Code / Cursor / etc."**
No problem. Conductor is IDE-agnostic. See `conductor-core/activation/{ide}/README.md` for each alternative. You can have multiple IDE adapters in the same repo simultaneously.

## Cross-References

This kit is referenced from `conductor-core/activation/README.md` and the top-level `README.md` Quick Start.
