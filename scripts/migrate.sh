#!/bin/bash
# scripts/migrate.sh — walk the migration chain from a given major to current.
#
# Migration is opt-in and forward-only: `make migrate from=<major>` runs each
# migrations/<i>-to-<i+1>.sh in order, up to the current major read from VERSION.
# Every migration script is idempotent (safe to re-run) and honours a no-write
# preview via dry_run=1. Empty in 1.0.0: there are no scripts yet, so
# `make migrate from=1` is a clean no-op (the first migration ships with 2.0.0).
set -euo pipefail

FROM="${1:-}"
DRY_RUN="${dry_run:-0}"

if [ ! -f VERSION ]; then
  echo "ERROR: VERSION file missing — cannot determine current version." >&2
  exit 1
fi

if ! echo "$FROM" | grep -qE '^[0-9]+$'; then
  echo "ERROR: unrecognised from='$FROM'; expected a numeric major version (e.g. from=1)." >&2
  exit 1
fi

CURRENT_MAJOR=$(cut -d. -f1 VERSION | tr -d '[:space:]')

# Run one migration script if it exists; return 1 (not fatal) when it is absent
# so the caller can report a no-op transition and continue down the chain.
run_script() {
  local script="$1"
  [ -f "$script" ] || return 1
  echo "Running $script (dry_run=$DRY_RUN)..."
  dry_run="$DRY_RUN" bash "$script"
}

i="$FROM"
while [ "$i" -lt "$CURRENT_MAJOR" ]; do
  NEXT=$((i + 1))
  if ! run_script "migrations/${i}-to-${NEXT}.sh"; then
    echo "No migration script at migrations/${i}-to-${NEXT}.sh — skipping (transition may be a no-op)."
  fi
  i="$NEXT"
done

echo "Migration complete: at major version $CURRENT_MAJOR."
