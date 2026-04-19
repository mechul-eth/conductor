#!/usr/bin/env bash
# Blocker resolution -- 3-role consensus on stuck tasks.
#
# When a task exhausts retries:
#  1. Write a CONSENSUS_REQUESTED marker.
#  2. Parent agent dispatches 3 subagents in parallel (different roles
#     or same role with different strategies) to propose fixes.
#  3. Parent synthesizes 2-of-3 convergent fix and applies it.
#  4. Parent writes CONSENSUS_RESULT: APPLIED | FAILED to the output file.
#
# Up to 3 rounds per task. After that, escalate.

readonly CONSENSUS_MAX_ROUNDS="${CONSENSUS_MAX_ROUNDS:-3}"
readonly CONSENSUS_WAIT_SECS="${CONSENSUS_WAIT_SECS:-1800}"

blocker_resolve() {
  local task_id="$1"
  local task_json="$2"
  local round=1

  log_warn "blocker" "Entering consensus for ${task_id}"

  # Write blocker context for collaborators
  _write_blocker_context "${task_id}" "${task_json}"

  while [[ ${round} -le ${CONSENSUS_MAX_ROUNDS} ]]; do
    log_info "blocker" "Consensus round ${round}/${CONSENSUS_MAX_ROUNDS}"

    local marker="${SCRIPT_DIR}/checkpoints/CONSENSUS_REQUESTED"
    local output_file="${SCRIPT_DIR}/checkpoints/consensus_${task_id//./_}_round_${round}.md"

    cat <<EOF > "${marker}"
TASK_ID: ${task_id}
ROUND: ${round}
BLOCKER_CONTEXT: ${BLOCKER_DIR}/${task_id}.md
OUTPUT_FILE: ${output_file}
REQUESTED_AT: $(date -u +%Y-%m-%dT%H:%M:%SZ)
TIMEOUT_SECS: ${CONSENSUS_WAIT_SECS}

The parent agent must:
  1. Read the blocker context at the path above.
  2. Dispatch 3 subagents IN PARALLEL via the Task tool. Each gets the blocker
     context and proposes an independent fix strategy.
  3. Synthesize the 3 responses. Pick the fix that 2 or more agree on
     (or the highest-confidence fix if no 2-of-3 convergence).
  4. Apply the fix (or reject all three if none is viable).
  5. Write CONSENSUS_RESULT: APPLIED or CONSENSUS_RESULT: FAILED to OUTPUT_FILE,
     followed by the full synthesis.
  6. Delete this CONSENSUS_REQUESTED marker.

The conductor will block until the marker is deleted OR TIMEOUT_SECS elapses.
EOF

    local elapsed=0 poll=10
    while [[ -f "${marker}" ]]; do
      sleep "${poll}"
      elapsed=$((elapsed + poll))
      if (( elapsed >= CONSENSUS_WAIT_SECS )); then
        log_error "blocker" "Consensus round ${round} timed out"
        rm -f "${marker}"
        break
      fi
    done

    if [[ -f "${output_file}" ]] && grep -q "^CONSENSUS_RESULT: APPLIED" "${output_file}"; then
      log_info "blocker" "Consensus round ${round}: APPLIED"
      return 0
    fi

    log_warn "blocker" "Consensus round ${round}: no applied fix -- next round"
    round=$((round + 1))
  done

  log_error "blocker" "Consensus exhausted (${CONSENSUS_MAX_ROUNDS} rounds) -- escalating"
  return 1
}

_write_blocker_context() {
  local task_id="$1" task_json="$2"
  local ctx="${BLOCKER_DIR}/${task_id}.md"

  # Pull the last output for context (if any)
  local last_output
  last_output="$(ls -t "${SCRIPT_DIR}/checkpoints/output_${task_id//./_}_attempt_"*.md 2>/dev/null | head -n 1)"

  {
    echo "# Blocker Context: ${task_id}"
    echo ""
    echo "Title: $(echo "${task_json}" | jq -r '.title')"
    echo "Role:  $(echo "${task_json}" | jq -r '.primary_role')"
    echo "Gates: $(echo "${task_json}" | jq -r '.gates | join(", ")')"
    echo ""
    echo "## Acceptance Criteria"
    echo ""
    echo "${task_json}" | jq -r '.acceptance_criteria[]?' | sed 's/^/- /'
    echo ""
    echo "## Recent State"
    echo ""
    echo '```jsonl'
    grep "\"task_id\":\"${task_id}\"" "${STATE_FILE}" | tail -n 5
    echo '```'
    echo ""
    if [[ -n "${last_output}" ]] && [[ -f "${last_output}" ]]; then
      echo "## Last Role Output (excerpt)"
      echo ""
      echo '```'
      tail -n 80 "${last_output}"
      echo '```'
    fi
  } > "${ctx}"

  log_info "blocker" "Blocker context written: ${ctx}"
}
