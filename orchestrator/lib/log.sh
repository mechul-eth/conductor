#!/usr/bin/env bash
# Structured logging -- credential-redacted.

_log() {
  local level="$1"
  local component="$2"
  local message="$3"
  local ts
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

  # Credential redaction (per CONDUCTOR.md safety policy)
  message="$(printf '%s' "${message}" | sed -E 's/(sk-[A-Za-z0-9_-]{20,})/[REDACTED-API-KEY]/g; s/(eyJ[A-Za-z0-9._-]{40,})/[REDACTED-JWT]/g; s/([0-9]{8,}:AA[A-Za-z0-9_-]{30,})/[REDACTED-BOT-TOKEN]/g; s/(dp\.pt\.[A-Za-z0-9]{30,})/[REDACTED-SECRET]/g')"

  local line="[${ts}] [${level}] [${component}] ${message}"
  echo "${line}" | tee -a "${LOG_FILE}" >&2
}

log_info()  { _log "INFO"  "$1" "$2"; }
log_warn()  { _log "WARN"  "$1" "$2"; }
log_error() { _log "ERROR" "$1" "$2"; }
log_debug() { [[ "${DEBUG:-0}" == "1" ]] && _log "DEBUG" "$1" "$2" || true; }
