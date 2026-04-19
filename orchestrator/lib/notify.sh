#!/usr/bin/env bash
# Notification helpers -- write checkpoint markers the parent IDE / user can act on.

notify_sprint_boundary() {
  local sprint="$1"
  local marker="${SCRIPT_DIR}/checkpoints/SPRINT_${sprint}_COMPLETE.md"
  cat <<EOF > "${marker}"
# Sprint ${sprint} complete

Time: $(date)

The orchestrator is advancing to the next sprint. No action required.
EOF
  log_info "notify" "Sprint boundary marker written: ${marker}"
}

notify_escalation() {
  local task_id="$1" reason="$2"
  local marker="${SCRIPT_DIR}/checkpoints/ESCALATED_${task_id//./_}.md"
  cat <<EOF > "${marker}"
# ESCALATED: Task ${task_id}

Time: $(date)
Reason: ${reason}

The orchestrator exhausted retries + consensus rounds for this task.
Human action required:
  1. Read ${BLOCKER_DIR}/${task_id}.md (consensus findings)
  2. Decide: fix manually, redefine acceptance criteria, or skip task
  3. Run: ./conductor.sh reset ${task_id} (then resume)

Rollback (if applicable):
  $(jq -r --arg id "${task_id}" '.tasks[] | select(.id == $id) | .rollback_command // "(no rollback declared in tasks.json)"' "${TASKS_FILE}")
EOF
  log_error "notify" "Escalation marker written: ${marker}"
}

notify_release_green() {
  local report_path="$1"
  local marker="${SCRIPT_DIR}/checkpoints/RELEASE_GREEN.md"
  cat <<EOF > "${marker}"
# RELEASE_GREEN

Time: $(date)
Report: ${report_path}

All declared tasks are COMPLETED. The pipeline is release-ready per the
gates defined in tasks.json. Next steps depend on your release-readiness
intelligence (conductor-core/business/release-readiness-intelligence/).
EOF
  log_info "notify" "RELEASE_GREEN marker written: ${marker}"
}
