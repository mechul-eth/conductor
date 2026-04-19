#!/usr/bin/env bash
# Auto-compact helper -- writes a COMPACT_REQUESTED marker the parent IDE
# picks up to run /compact (or equivalent context-window compaction).
#
# In cli dispatch mode, no compaction is done -- each claude --print call
# starts a fresh context anyway.

compact_context() {
  local task_id="$1"
  local mode="${CONDUCTOR_DISPATCH_MODE:-auto}"

  if [[ "${mode}" == "cli" ]]; then
    log_info "compact" "cli mode -- no compaction needed"
    return 0
  fi

  if [[ "${CONDUCTOR_NO_COMPACT:-0}" == "1" ]]; then
    log_info "compact" "Compaction disabled via CONDUCTOR_NO_COMPACT"
    return 0
  fi

  local marker="${SCRIPT_DIR}/checkpoints/COMPACT_REQUESTED"
  cat <<EOF > "${marker}"
TASK_ID: ${task_id}
REQUESTED_AT: $(date -u +%Y-%m-%dT%H:%M:%SZ)

Task ${task_id} just COMPLETED. The parent agent should run /compact (or the
equivalent context-window compaction command) before the next dispatch to
prevent drift across tasks.

After compacting, delete this marker.
EOF
  log_info "compact" "Compact marker written after ${task_id}"

  # Soft-wait: give the parent up to 60s. If they don't pick it up, proceed anyway.
  local elapsed=0
  while [[ -f "${marker}" ]] && (( elapsed < 60 )); do
    sleep 5
    elapsed=$((elapsed + 5))
  done

  if [[ -f "${marker}" ]]; then
    log_warn "compact" "Parent did not handle compact marker in 60s -- proceeding"
    rm -f "${marker}"
  else
    log_info "compact" "Parent handled compact"
  fi
}
