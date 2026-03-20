#!/usr/bin/env bash
# Conductor Bootstrap — generates IDE instruction file + runs first-time setup
#
# Usage:
#   ./mg-mode-core/activation/bootstrap.sh [--ide <ide>]
#
# Supported IDEs: copilot, claude, cursor, codex, windsurf, aider, gemini
# If --ide is omitted, auto-detects from environment.

set -euo pipefail

CONDUCTOR_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CORE_DIR="$CONDUCTOR_ROOT/mg-mode-core"
STATE_DIR="$HOME/.conductor"

# Colors (if terminal supports them)
if [[ -t 1 ]]; then
  GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
else
  GREEN=''; YELLOW=''; RED=''; NC=''
fi

info()  { echo -e "${GREEN}[conductor]${NC} $1"; }
warn()  { echo -e "${YELLOW}[conductor]${NC} $1"; }
error() { echo -e "${RED}[conductor]${NC} $1" >&2; }

# --- IDE Detection ---
detect_ide() {
  if [[ -n "${VSCODE_PID:-}" ]] || [[ -n "${TERM_PROGRAM:-}" && "$TERM_PROGRAM" == "vscode" ]]; then
    echo "copilot"
  elif [[ -n "${CLAUDE_CODE:-}" ]] || [[ -f "$CONDUCTOR_ROOT/CLAUDE.md" && -d "$HOME/.claude" ]]; then
    echo "claude"
  elif [[ -n "${CURSOR_SESSION:-}" ]] || [[ -f "$CONDUCTOR_ROOT/.cursorrules" ]]; then
    echo "cursor"
  elif command -v codex &>/dev/null && [[ -d "$HOME/.codex" ]]; then
    echo "codex"
  elif [[ -f "$CONDUCTOR_ROOT/.windsurfrules" ]]; then
    echo "windsurf"
  elif command -v aider &>/dev/null; then
    echo "aider"
  elif command -v gemini &>/dev/null; then
    echo "gemini"
  else
    echo "unknown"
  fi
}

# --- Parse Args ---
IDE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ide) IDE="$2"; shift 2 ;;
    *) error "Unknown argument: $1"; exit 1 ;;
  esac
done

if [[ -z "$IDE" ]]; then
  IDE="$(detect_ide)"
  if [[ "$IDE" == "unknown" ]]; then
    warn "Could not auto-detect IDE. Defaulting to 'claude'."
    warn "Use --ide <copilot|claude|cursor|codex|windsurf|aider|gemini> to specify."
    IDE="claude"
  fi
fi
info "Detected IDE: $IDE"

# --- Generate Instruction Content ---
generate_instructions() {
  cat <<'INSTRUCTIONS'
# Conductor — Orchestration Layer

You are operating under Conductor, a two-layer orchestration system.

## Layer 1 — Libraries (read-only, invoke directly)
- agency-agents/: 156 agent role definitions across 13 domains
- gstack/: 21 workflow skills with binary entry points
- promptfoo/: 85+ validation and red-team plugins

## Layer 2 — Brain (mg-mode-core/)
- CONDUCTOR.md: Master policy and routing rules
- identity/: Agent trust and authorization
- graph/: Semantic code graph
- map/: Pre/during/post execution planning
- optimizer/: Cost routing and circuit breaker
- governance/: Automation value gate
- profiles/: Stage-aware configuration
- session/: Cross-role state persistence
- business/: Per-project business intelligence — user, product, market (created on first activation)
- activation/: Bootstrap (already running)
- registry/: Machine-readable role catalog (156 roles + 21 skills)
- conductor/: Unified entry point and orchestration flow

## Behavioral Rules
1. NEVER invent a role. Use only roles defined in agency-agents/.
2. ALWAYS run through map/ before executing. Pre-execution planning is mandatory.
3. RESPECT the active profile's budget caps, validation groups, and gate requirements.
4. PERSIST results to session/ after every task completion.
5. VALIDATE through promptfoo/ when the profile requires it.
6. ROUTE cost decisions through optimizer/ — cheapest viable model first.
7. ASK before acting when blast radius > 5 files or action is irreversible.

## Start
Read mg-mode-core/CONDUCTOR.md now. That is your master instruction set.
Then read mg-mode-core/conductor/README.md for the orchestration flow.
INSTRUCTIONS
}

# --- Write IDE-Specific File ---
case "$IDE" in
  copilot)
    TARGET="$CONDUCTOR_ROOT/.github/copilot-instructions.md"
    mkdir -p "$(dirname "$TARGET")"
    ;;
  claude)
    TARGET="$CONDUCTOR_ROOT/CLAUDE.md"
    ;;
  cursor)
    TARGET="$CONDUCTOR_ROOT/.cursorrules"
    ;;
  codex)
    TARGET="$CONDUCTOR_ROOT/AGENTS.md"
    ;;
  windsurf)
    TARGET="$CONDUCTOR_ROOT/.windsurfrules"
    ;;
  aider)
    TARGET="$CONDUCTOR_ROOT/CONVENTIONS.md"
    ;;
  gemini)
    TARGET="$CONDUCTOR_ROOT/GEMINI.md"
    ;;
  *)
    error "Unsupported IDE: $IDE"
    exit 1
    ;;
esac

# Safety: don't overwrite existing files without confirmation
if [[ -f "$TARGET" ]]; then
  warn "File already exists: $TARGET"
  warn "Backing up to ${TARGET}.bak"
  cp "$TARGET" "${TARGET}.bak"
fi

generate_instructions > "$TARGET"
info "Wrote instruction file: $TARGET"

# --- Initialize Layer 1 Submodules (if in a git repo and not yet initialized) ---
if git -C "$CONDUCTOR_ROOT" rev-parse --is-inside-work-tree &>/dev/null; then
  SUBMODULE_FILE="$CONDUCTOR_ROOT/.gitmodules"
  if [[ -f "$SUBMODULE_FILE" ]]; then
    # Check if any submodule directory is missing or empty
    NEEDS_INIT=false
    for dir in agency-agents gstack promptfoo; do
      if [[ ! -d "$CONDUCTOR_ROOT/$dir" ]] || [[ -z "$(ls -A "$CONDUCTOR_ROOT/$dir" 2>/dev/null)" ]]; then
        NEEDS_INIT=true
        break
      fi
    done

    if [[ "$NEEDS_INIT" == "true" ]]; then
      info "Initializing Layer 1 submodules (agency-agents, gstack)..."
      info "Note: promptfoo is large (~750MB). Skipping unless you need validation."
      git -C "$CONDUCTOR_ROOT" submodule update --init agency-agents gstack 2>&1 || \
        warn "Submodule init failed — you can run: git submodule update --init agency-agents gstack"
      info "To also initialize promptfoo (for validation features): git submodule update --init promptfoo"
    fi
  fi
fi

# --- Disable Layer 1 Proactive Mode ---
GSTACK_CONFIG="$CONDUCTOR_ROOT/gstack/bin/gstack-config"
if [[ -x "$GSTACK_CONFIG" ]]; then
  "$GSTACK_CONFIG" set proactive false
  info "Disabled Layer 1 proactive mode (gstack-config set proactive false)"
else
  warn "gstack-config not found at $GSTACK_CONFIG — skipping proactive disable"
fi

# --- Initialize State Directory ---
mkdir -p "$STATE_DIR/sessions"
mkdir -p "$STATE_DIR/analytics"
mkdir -p "$STATE_DIR/projects"
info "Initialized state directory: $STATE_DIR"

# --- Initialize Business Intelligence Directory ---
BIZ_DIR="$CONDUCTOR_ROOT/mg-mode-core/business"
BIZ_TEMPLATE="$CORE_DIR/business"
if [ ! -d "$BIZ_DIR" ] || [ -z "$(ls -A "$BIZ_DIR" 2>/dev/null)" ]; then
  if [ -d "$BIZ_TEMPLATE" ]; then
    info "Business intelligence directory already initialized at: $BIZ_DIR"
  else
    mkdir -p "$BIZ_DIR"
    info "Created business intelligence directory: $BIZ_DIR"
    warn "No template files found in $BIZ_TEMPLATE — business/ created empty."
    warn "Run onboarding to populate it: 'Activate Conductor' in your IDE."
  fi
else
  info "Business intelligence directory exists: $BIZ_DIR"
fi

# --- Done ---
echo ""
info "Conductor bootstrap complete."
info ""
info "Next steps:"
info "  1. Open your IDE agent chat"
info "  2. The instruction file at $TARGET will be loaded automatically"
info "  3. Say: 'Activate Conductor' — the agent will read CONDUCTOR.md and start onboarding"
info "  4. Answer the 3 profile questions (stage, domain, scenario)"
info "  5. Start working"
echo ""
