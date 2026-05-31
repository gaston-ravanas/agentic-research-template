#!/usr/bin/env bash
# scripts/close-conflict.sh — close an open conflict (§I3, §commit-scopes).
#
# Invocation (via Makefile):
#   make close-conflict file=conflicts/<name>.md
#
# The CLOSING side of the single disagreement lifecycle (§I3):
#   make open-conflict  →  think (run on the file)  →  make close-conflict
#
# Verifies the file is a real conflict with current `status: open`, then flips
# status to `closed`, stamps `resolved_at` from `make now` (restoring the iff:
# status:closed ⇔ resolved_at is a timestamp, §I3), stages the file, and commits
# under the `conflict:` scope (§commit-scopes): `conflict: close <basename>`.
#
# Aborts with a clear, line-prefixed message if anything is off (file missing,
# already closed, frontmatter malformed). Pure bash + awk/grep/sed.

set -e

FILE="$1"

if [ -z "$FILE" ]; then
  echo "Usage: make close-conflict file=conflicts/<name>.md"
  exit 1
fi

if [ ! -f "$FILE" ]; then
  echo "${FILE}:0: file not found; check the path"
  exit 1
fi

# Scope guard: only operate on conflicts/ files.
case "$FILE" in
  conflicts/*.md) ;;
  *)
    echo "${FILE}:0: not a conflict file; expected a path under conflicts/"
    exit 1
    ;;
esac

# Never close the schema doc.
if [ "$(basename "$FILE")" = "TEMPLATE.md" ]; then
  echo "${FILE}:0: refusing to close TEMPLATE.md"
  exit 1
fi

# Parse the first frontmatter block (between the first two '---' lines).
FRONTMATTER=$(awk '
  BEGIN { in_fm=0; count=0 }
  /^---[[:space:]]*$/ {
    count++
    if (count==1) { in_fm=1; next }
    if (count==2) { in_fm=0; exit }
  }
  in_fm { print }
' "$FILE")

if [ -z "$FRONTMATTER" ]; then
  echo "${FILE}:1: missing frontmatter; expected '---' delimited YAML at top of file"
  exit 1
fi

# Current status must be 'open'.
STATUS=$(echo "$FRONTMATTER" | grep -E '^status:' | head -1 | sed -E 's/^status:[[:space:]]*//')
if [ -z "$STATUS" ]; then
  echo "${FILE}:2: missing required field 'status'; add 'status: open' to frontmatter"
  exit 1
fi
if [ "$STATUS" = "closed" ]; then
  echo "${FILE}:2: status is already 'closed'; nothing to do"
  exit 1
fi
if [ "$STATUS" != "open" ]; then
  echo "${FILE}:2: invalid status '$STATUS'; expected 'open' or 'closed'"
  exit 1
fi

# resolved_at must exist (we replace it).
if ! echo "$FRONTMATTER" | grep -qE '^resolved_at:'; then
  echo "${FILE}:4: missing required field 'resolved_at'; add 'resolved_at: null' to frontmatter"
  exit 1
fi

TS_DISPLAY="$(bash scripts/now.sh)"

# Edit only the frontmatter block; leave the body untouched. awk + mktemp + mv —
# never `sed -i` (BSD and GNU sed disagree). Every '---' line is printed exactly
# once (the unconditional `next` after the delimiter block prevents double-print
# if the body itself contains a horizontal rule).
TMP="$(mktemp)"
awk -v ts="$TS_DISPLAY" '
  BEGIN { in_fm=0; count=0 }
  /^---[[:space:]]*$/ {
    count++
    print
    if (count==1) in_fm=1
    if (count==2) in_fm=0
    next
  }
  in_fm && /^status:/      { print "status: closed"; next }
  in_fm && /^resolved_at:/ { print "resolved_at: " ts; next }
  { print }
' "$FILE" > "$TMP"

mv "$TMP" "$FILE"

# Verify the edit landed.
if ! grep -qE '^status: closed$' "$FILE"; then
  echo "${FILE}:2: failed to update status to 'closed' (internal error)"
  exit 1
fi
if ! grep -qE "^resolved_at: ${TS_DISPLAY}$" "$FILE"; then
  echo "${FILE}:4: failed to update resolved_at (internal error)"
  exit 1
fi

# Stage and commit only this path (scope-clean: never sweep unrelated staged work).
git add -- "$FILE"
BASENAME="$(basename "$FILE" .md)"
git commit -m "conflict: close ${BASENAME}" -- "$FILE"

echo "Closed $FILE"
