#!/usr/bin/env bash
# scripts/validate-journal.sh — BLOCKING structural validator for JOURNAL.md (§I8).
#
# JOURNAL.md is the append-only, newest-first, load-bearing memory surface (§I8):
# nothing rewrites a past entry, so it cannot go stale. This checker enforces the
# shape the `log` skill (and any human) must keep:
#
#   - the file exists;
#   - line 1 is exactly the heading '# JOURNAL.md — Research Log';
#   - every '## ' entry heading is 'YYYY-MM-DD HH:MM' (an optional parenthetical
#     suffix like '(project start)' is allowed);
#   - the literal bootstrap placeholder '## YYYY-MM-DD HH:MM (project start)' is
#     accepted verbatim (and ignored for ordering) so a freshly minted repo passes;
#   - entries appear newest-first (each entry's timestamp ≤ the one above it).
#
# Blocking (§I2): exit 1 on any malformed structure, 0 otherwise. Errors are
# line-prefixed '<file>:<line>: <problem>'. Discovered and run by `make validate`
# via the scripts/validate-*.sh glob; also reachable as `make validate-journal`.
#
# Error accumulation (no `set -e`) matches scripts/validate-frontmatter.sh: every
# problem surfaces, one never masks the next.

FILE="JOURNAL.md"
ERRORS=0

if [ ! -f "$FILE" ]; then
  echo "$FILE:0: file missing; run scripts/setup.sh or restore it from the template" >&2
  exit 1
fi

# Line 1 must be the canonical heading (em-dash, exact text).
HEADING="$(head -n 1 "$FILE")"
if [ "$HEADING" != "# JOURNAL.md — Research Log" ]; then
  echo "$FILE:1: top-level heading missing or malformed; expected '# JOURNAL.md — Research Log'" >&2
  ERRORS=1
fi

# Validate each '## ' entry heading, top-down. Process substitution (not a pipe)
# keeps the loop in the current shell so ERRORS survives it.
PREV_TS=""
while IFS= read -r LINE; do
  [ -z "$LINE" ] && continue
  LNO="${LINE%%:*}"            # leading line number from grep -n
  TEXT="${LINE#*:}"            # the heading line itself
  CONTENT="${TEXT#\#\# }"      # strip the leading '## '

  # Accept the bootstrap placeholder verbatim; skip it for ordering so a
  # freshly bootstrapped repo (only this entry) passes.
  if [ "$CONTENT" = "YYYY-MM-DD HH:MM (project start)" ]; then
    continue
  fi

  TS="$(echo "$CONTENT" | grep -oE '^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}')"
  if [ -z "$TS" ]; then
    echo "$FILE:$LNO: invalid entry heading '$CONTENT'; expected 'YYYY-MM-DD HH:MM' (optional '(suffix)' allowed)" >&2
    ERRORS=1
    continue
  fi

  # Newest-first: reading top-down, each timestamp must be ≤ the one above it.
  # Lexical comparison is chronological for the fixed 'YYYY-MM-DD HH:MM' shape.
  if [ -n "$PREV_TS" ] && [ "$TS" \> "$PREV_TS" ]; then
    echo "$FILE:$LNO: entry out of order (newer than the entry above); JOURNAL.md is newest-first" >&2
    ERRORS=1
  fi
  PREV_TS="$TS"
done < <(grep -n '^## ' "$FILE")

if [ "$ERRORS" -ne 0 ]; then
  echo "validate-journal: FAILED — fix JOURNAL.md above." >&2
  exit 1
fi
echo "validate-journal: structure OK."
exit 0
