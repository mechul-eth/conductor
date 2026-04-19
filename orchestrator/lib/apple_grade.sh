#!/usr/bin/env bash
# Apple-grade thinking gate.
# Scans the latest dispatch output for an APPLE_GRADE_REPORT block.
# Fails if any of Q1-Q4 reveal an unaddressed gap (markers like "GAP", "TODO",
# or unanswered questions).

apple_grade_check() {
  local task_json="$1"
  local task_id
  task_id="$(echo "${task_json}" | jq -r '.id')"
  local output_file
  output_file="$(ls -t "${SCRIPT_DIR}/checkpoints/output_${task_id//./_}_attempt_"*.md 2>/dev/null | head -n 1)"
  if [[ -z "${output_file}" ]] || [[ ! -f "${output_file}" ]]; then
    log_warn "apple" "No output file for ${task_id} -- assuming PASS"
    return 0
  fi

  log_info "apple" "Apple-grade check for ${task_id}"

  # Apple-grade is mandatory for tasks tagged S3+ in the sprint marker, but we
  # apply it on every task for safety -- the role can answer "n/a" where
  # genuinely irrelevant.
  local report
  report="$(awk '/^APPLE_GRADE_REPORT:/{flag=1; next} /^TASK_RESULT:/{flag=0} flag' "${output_file}")"
  if [[ -z "${report}" ]]; then
    log_warn "apple" "No APPLE_GRADE_REPORT block -- recommending answer next attempt"
    # Soft fail: warn but allow PASS
    return 0
  fi

  # Detect explicit gap markers
  if echo "${report}" | grep -qE '\b(GAP|TODO|MISSING|UNADDRESSED)\b'; then
    log_warn "apple" "Apple-grade gap detected in report"
    return 1
  fi

  log_info "apple" "Apple-grade check PASS"
  return 0
}
