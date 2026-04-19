#!/usr/bin/env bash
# ============================================================================
# Conductor Autonomous Orchestrator
# ----------------------------------------------------------------------------
# Modular, deterministic-first runtime for multi-phase pipelines.
# Reads tasks.json, dispatches to roles, runs quality gates, auto-retries,
# escalates to consensus on blockers, auto-compacts between tasks.
#
# Usage:
#   ./conductor.sh start              # First-time kickoff (creates state.jsonl)
#   ./conductor.sh resume             # Resume from last checkpoint
#   ./conductor.sh status             # Show current state without executing
#   ./conductor.sh preflight          # Deep readiness audit (run before kickoff)
#   ./conductor.sh validate-state     # Verify state.jsonl integrity
#   ./conductor.sh halt               # Write HALT checkpoint, stop loop
#   ./conductor.sh reset <id>         # Reset a specific task to PENDING (admin)
#
# Hard rules (from conductor-core/CONDUCTOR.md):
#   - Deterministic-first
#   - Minimum-role-set routing
#   - No silent scope expansion
#   - Auto-compact between tasks
#   - world-class thinking required before COMPLETED
#   - Every task ends with TASK_RESULT: PASS or FAIL
# ============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
readonly SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
readonly REPO_ROOT="$( cd "${SCRIPT_DIR}/.." && pwd )"
readonly TASKS_FILE="${SCRIPT_DIR}/tasks.json"
readonly STATE_FILE="${SCRIPT_DIR}/state.jsonl"
readonly LOG_DIR="${SCRIPT_DIR}/logs"
readonly BLOCKER_DIR="${SCRIPT_DIR}/blockers"
readonly LIB_DIR="${SCRIPT_DIR}/lib"
readonly GATES_DIR="${SCRIPT_DIR}/gates"
readonly ROLES_DIR="${SCRIPT_DIR}/roles"
readonly TODAY="$(date +%Y-%m-%d)"
readonly LOG_FILE="${LOG_DIR}/conductor-${TODAY}.log"

mkdir -p "${LOG_DIR}" "${BLOCKER_DIR}" "${SCRIPT_DIR}/checkpoints"

# Source helpers (order matters: log first, then lock, then state)
# shellcheck source=lib/log.sh
source "${LIB_DIR}/log.sh"
# shellcheck source=lib/lock.sh
source "${LIB_DIR}/lock.sh"
# shellcheck source=lib/state.sh
source "${LIB_DIR}/state.sh"
# shellcheck source=lib/notify.sh
source "${LIB_DIR}/notify.sh"
# shellcheck source=lib/preflight.sh
source "${LIB_DIR}/preflight.sh"
# shellcheck source=lib/gates.sh
source "${LIB_DIR}/gates.sh"
# shellcheck source=lib/dispatch.sh
source "${LIB_DIR}/dispatch.sh"
# shellcheck source=lib/blocker.sh
source "${LIB_DIR}/blocker.sh"
# shellcheck source=lib/compact.sh
source "${LIB_DIR}/compact.sh"
# shellcheck source=lib/world_standard.sh
source "${LIB_DIR}/world_standard.sh"

# ---------------------------------------------------------------------------
# Command: preflight
# ---------------------------------------------------------------------------
cmd_preflight() {
  preflight_deep
}

# ---------------------------------------------------------------------------
# Command: validate-state
# ---------------------------------------------------------------------------
cmd_validate_state() {
  if state_validate; then
    echo "state.jsonl is well-formed"
    exit 0
  else
    echo "state.jsonl is corrupt -- restore from ${STATE_FILE}.bak or archive and restart"
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Command: start
# ---------------------------------------------------------------------------
cmd_start() {
  if [[ ! -f "${TASKS_FILE}" ]]; then
    log_error "start" "tasks.json not found at ${TASKS_FILE}"
    log_info  "start" "Copy orchestrator/tasks.example.json to tasks.json and edit it for your project"
    exit 1
  fi

  if [[ -f "${STATE_FILE}" ]]; then
    log_warn "start" "state.jsonl already exists -- use 'resume' instead"
    log_info "start" "If you want to restart from scratch, archive state.jsonl manually first"
    exit 1
  fi

  log_info "start" "============================================"
  log_info "start" "CONDUCTOR ORCHESTRATOR -- KICKOFF"
  log_info "start" "============================================"

  state_init
  cmd_resume
}

# ---------------------------------------------------------------------------
# Command: resume
# ---------------------------------------------------------------------------
cmd_resume() {
  if [[ ! -f "${STATE_FILE}" ]]; then
    log_warn "resume" "No state.jsonl -- nothing to resume. Run 'start' first."
    exit 0
  fi

  # Acquire master lock so a parallel cron resumer doesn't double-run
  if ! lock_master_acquire; then
    log_info "resume" "Another conductor instance holds the master lock -- exiting cleanly"
    exit 0
  fi

  log_info "resume" "Resuming conductor from last checkpoint"
  local current_sprint=""

  while true; do
    local current_task_id
    current_task_id="$(state_get_next_task)"

    case "${current_task_id}" in
      ALL_DONE)
        log_info "resume" "ALL TASKS COMPLETED -- RELEASE_GREEN"
        state_append "ALL_DONE" "ALL_DONE" 0 "{}" "Pipeline complete"
        local report_path
        report_path="$(generate_final_report)"
        notify_release_green "${report_path}"
        exit 0
        ;;
      HALT)
        log_warn "resume" "HALT checkpoint detected -- orchestrator stopped"
        exit 0
        ;;
      ESCALATED)
        log_error "resume" "ESCALATED checkpoint -- user notification required"
        exit 0
        ;;
    esac

    # Idempotency: if next task is already COMPLETED, advance rather than re-execute.
    if state_is_completed "${current_task_id}"; then
      log_warn "resume" "Task ${current_task_id} already COMPLETED -- advancing"
      state_append "${current_task_id}" "COMPLETED" 0 "{\"reason\":\"idempotent_skip\"}" "Already complete; advancing"
      continue
    fi

    # Sprint boundary detection (informational notify)
    local task_sprint
    task_sprint="$(jq -r --arg id "${current_task_id}" '.tasks[] | select(.id == $id) | .sprint // ""' "${TASKS_FILE}")"
    if [[ -n "${current_sprint}" ]] && [[ -n "${task_sprint}" ]] && [[ "${task_sprint}" != "${current_sprint}" ]]; then
      notify_sprint_boundary "${current_sprint}"
    fi
    current_sprint="${task_sprint}"

    log_info "resume" "Next task: ${current_task_id} (${task_sprint:-no-sprint})"

    if ! execute_task "${current_task_id}"; then
      log_error "resume" "Task ${current_task_id} failed terminally -- orchestrator halting"
      exit 1
    fi

    compact_context "${current_task_id}"
  done
}

# ---------------------------------------------------------------------------
# Command: status
# ---------------------------------------------------------------------------
cmd_status() {
  if [[ ! -f "${STATE_FILE}" ]]; then
    echo "Conductor not started. Run: ./conductor.sh start"
    exit 0
  fi

  echo "============================================"
  echo "CONDUCTOR STATUS -- $(date)"
  echo "============================================"
  echo ""
  echo "Total tasks: $(jq '.tasks | length' "${TASKS_FILE}")"
  echo "Completed:   $(grep -c '"status":"COMPLETED"' "${STATE_FILE}" || echo 0)"
  echo "Blocked:     $(grep -c '"status":"BLOCKED"' "${STATE_FILE}" || echo 0)"
  echo "Escalated:   $(grep -c '"status":"ESCALATED"' "${STATE_FILE}" || echo 0)"
  echo ""
  echo "Last 3 checkpoints:"
  tail -n 3 "${STATE_FILE}" | jq -c '{ts: .timestamp, task: .task_id, status: .status, attempt: .attempt}'
  echo ""
  echo "Next task: $(state_get_next_task)"
  echo ""
  if ls "${SCRIPT_DIR}/checkpoints/ESCALATED_"* >/dev/null 2>&1; then
    echo "ESCALATED markers present:"
    ls -1 "${SCRIPT_DIR}/checkpoints/ESCALATED_"*
  fi
  if [[ -f "${LOCK_MASTER_FILE}" ]]; then
    echo "Master lock held by pid $(cat "${LOCK_MASTER_FILE}" 2>/dev/null || echo '?')"
  fi
}

# ---------------------------------------------------------------------------
# Command: halt
# ---------------------------------------------------------------------------
cmd_halt() {
  state_append "HALT" "HALT" 0 "{}" "User-initiated halt"
  log_warn "halt" "HALT checkpoint written"
}

# ---------------------------------------------------------------------------
# Command: reset
# ---------------------------------------------------------------------------
cmd_reset() {
  local task_id="${1:-}"
  if [[ -z "${task_id}" ]]; then
    echo "Usage: ./conductor.sh reset <task_id>"
    exit 1
  fi
  state_append "${task_id}" "PENDING" 0 "{}" "Manual reset"
  log_warn "reset" "Task ${task_id} reset to PENDING"
}

# ---------------------------------------------------------------------------
# Core: execute a single task with full retry + consensus loop
# ---------------------------------------------------------------------------
execute_task() {
  local task_id="$1"
  local max_retries
  max_retries="$(jq -r '.global_constraints.max_retries_per_task // 3' "${TASKS_FILE}")"

  local task_json
  task_json="$(jq --arg id "${task_id}" '.tasks[] | select(.id == $id)' "${TASKS_FILE}")"

  if [[ -z "${task_json}" ]]; then
    log_error "execute" "Task ${task_id} not found in tasks.json"
    return 1
  fi

  local title role gates_arr
  title="$(echo "${task_json}" | jq -r '.title')"
  role="$(echo "${task_json}" | jq -r '.primary_role')"
  gates_arr="$(echo "${task_json}" | jq -r '.gates | join(",")')"

  log_info "execute" "-----------------------------------------"
  log_info "execute" "TASK ${task_id}: ${title}"
  log_info "execute" "Role: ${role} | Gates: ${gates_arr}"
  log_info "execute" "-----------------------------------------"

  state_append "${task_id}" "IN_PROGRESS" 0 "{}" "Task started"

  local attempt=1
  while [[ ${attempt} -le ${max_retries} ]]; do
    log_info "execute" "Attempt ${attempt}/${max_retries}"

    if ! gate_pre_execution "${task_json}"; then
      log_error "execute" "Pre-execution gate failed"
      state_append "${task_id}" "BLOCKED" "${attempt}" "{\"reason\":\"pre_execution_gate\"}" "Pre-gate failed"
      blocker_resolve "${task_id}" "${task_json}" || return 1
      ((attempt++))
      continue
    fi

    local exec_result
    if dispatch_to_role "${task_json}" "${attempt}"; then
      exec_result="success"
    else
      exec_result="failed"
    fi

    if [[ "${exec_result}" == "failed" ]]; then
      log_warn "execute" "Role execution failed on attempt ${attempt}"
      state_append "${task_id}" "PARTIAL" "${attempt}" "{\"reason\":\"role_exec_failed\"}" "Will retry"
      ((attempt++))
      continue
    fi

    # Implicit gate: every task gets H_acceptance after dispatch.
    if ! gate_h_acceptance "${task_json}"; then
      log_warn "execute" "Acceptance criteria gate failed -- retrying"
      state_append "${task_id}" "PARTIAL" "${attempt}" "{\"failed_gate\":\"H_acceptance\"}" "Acceptance criteria not all met"
      ((attempt++))
      continue
    fi

    # Explicit per-task gates
    local gates_passed=true gate=""
    IFS=',' read -ra GATES <<< "${gates_arr}"
    for gate in "${GATES[@]}"; do
      if ! gate_run "${gate}" "${task_json}"; then
        log_warn "execute" "Gate ${gate} FAILED"
        gates_passed=false
        break
      fi
      log_info "execute" "Gate ${gate} PASS"
    done

    if [[ "${gates_passed}" == "false" ]]; then
      state_append "${task_id}" "PARTIAL" "${attempt}" "{\"failed_gate\":\"${gate}\"}" "Gate failure"
      ((attempt++))
      continue
    fi

    # world-class thinking gate
    if ! world_standard_check "${task_json}"; then
      log_warn "execute" "world-class check identified gaps -- auto-extending task"
      state_append "${task_id}" "PARTIAL" "${attempt}" "{\"reason\":\"world_standard_gap\"}" "World-standard gaps found"
      ((attempt++))
      continue
    fi

    state_append_idempotent "${task_id}" "COMPLETED" "${attempt}" "{\"gates\":\"${gates_arr}\"}" "All gates PASS"
    log_info "execute" "Task ${task_id} COMPLETED"
    return 0
  done

  log_warn "execute" "Retry budget exhausted for ${task_id} -- invoking consensus blocker resolution"
  state_append "${task_id}" "BLOCKED" "${attempt}" "{\"reason\":\"retry_budget_exhausted\"}" "Entering consensus"

  if blocker_resolve "${task_id}" "${task_json}"; then
    state_append_idempotent "${task_id}" "COMPLETED" "${attempt}" "{\"resolved_by\":\"consensus\"}" "Consensus fix applied"
    return 0
  else
    state_append "${task_id}" "ESCALATED" "${attempt}" "{\"reason\":\"consensus_failed\"}" "Requires human"
    notify_escalation "${task_id}" "consensus_failed_after_retries_and_rounds"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# Final report generator (returns the report path on stdout)
# ---------------------------------------------------------------------------
generate_final_report() {
  local report="${SCRIPT_DIR}/release-report-$(date +%Y%m%d-%H%M%S).md"
  log_info "report" "Generating final report: ${report}"
  {
    echo "# Conductor Release Report"
    echo ""
    echo "Generated: $(date)"
    echo ""
    echo "## Summary"
    echo ""
    echo "- Total tasks: $(jq '.tasks | length' "${TASKS_FILE}")"
    echo "- Completed:   $(grep -c '"status":"COMPLETED"' "${STATE_FILE}")"
    echo "- Final verdict: RELEASE_GREEN"
    echo ""
    echo "## Per-sprint summary"
    echo ""
    local sprints
    sprints="$(jq -r '[.tasks[].sprint] | unique | .[]' "${TASKS_FILE}" 2>/dev/null || true)"
    for sprint in ${sprints}; do
      local count
      count="$(jq -r --arg s "${sprint}" '[.tasks[] | select(.sprint == $s)] | length' "${TASKS_FILE}")"
      echo "- ${sprint}: ${count} tasks"
    done
    echo ""
    echo "## Evidence Ledger"
    echo ""
    echo '```jsonl'
    cat "${STATE_FILE}"
    echo '```'
  } > "${report}"
  log_info "report" "Report written: ${report}"
  echo "${report}"
}

# ---------------------------------------------------------------------------
# Entrypoint
# ---------------------------------------------------------------------------
main() {
  preflight_basic

  local cmd="${1:-resume}"
  shift || true

  case "${cmd}" in
    start)            cmd_start "$@" ;;
    resume)           cmd_resume "$@" ;;
    status)           cmd_status "$@" ;;
    preflight)        cmd_preflight "$@" ;;
    validate-state)   cmd_validate_state "$@" ;;
    halt)             cmd_halt "$@" ;;
    reset)            cmd_reset "$@" ;;
    *)
      cat <<USAGE
Usage: $0 <command>

Commands:
  start              First-time kickoff (creates state.jsonl, runs first task)
  resume             Resume from last checkpoint (safe to call repeatedly)
  status             Show current state without executing
  preflight          Deep readiness audit -- run this BEFORE 'start'
  validate-state     Verify state.jsonl integrity
  halt               Write HALT checkpoint, stop loop
  reset <task_id>    Reset a specific task to PENDING (admin override)
USAGE
      exit 1
      ;;
  esac
}

main "$@"
