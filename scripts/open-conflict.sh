#!/usr/bin/env bash
# scripts/open-conflict.sh — open one disagreement in conflicts/ (§I3, §I10).
#
# Invocation (via Makefile):
#   make open-conflict claim=C#### check=<id> repair_side=<program|argument|undecided>
#
# Mints the conflict file
#   conflicts/<ts>-<claim>-check-<check-slug>.md
# with shell-stamped conflict frontmatter (status: open, resolved_at: null — the
# iff, §I3; detected_at from `make now`) and lays the conflicts/TEMPLATE.md body
# underneath, so skills never hand-roll a conflict's shape. This is the OPENING
# side of the single lifecycle (§I3):
#
#   make open-conflict  →  think (run on the file)  →  make close-conflict
#
# It does NOT commit. Opening a dispute is non-committal: the `build` skill or the
# user decides when the conflict is worth committing (under the `conflict:` scope).
#
# Pure bash + awk/sed/grep. No language runtime required.

set -e

CLAIM="$1"
CHECK="$2"
REPAIR="$3"

usage() {
  echo "Usage: make open-conflict claim=C#### check=<id> repair_side=<program|argument|undecided>"
}

if [ -z "$CLAIM" ] || [ -z "$CHECK" ] || [ -z "$REPAIR" ]; then
  usage
  exit 1
fi

# claim must be C#### (§I10).
if ! printf '%s' "$CLAIM" | grep -qE '^C[0-9]{4}$'; then
  echo "Invalid claim '$CLAIM'. Expected 'C' followed by exactly four digits (e.g. C0007)."
  exit 1
fi

# repair_side enum (§I3) — where the NEXT session looks first.
case "$REPAIR" in
  program|argument|undecided) ;;
  *)
    echo "Invalid repair_side '$REPAIR'. Must be one of program|argument|undecided."
    exit 1
    ;;
esac

# The frontmatter keeps the raw check id (e.g. 7.2); the filename uses a slug of it
# (lowercase, non-alphanumeric → hyphen, collapsed, trimmed): 7.2 → 7-2.
CHECK_SLUG="$(printf '%s' "$CHECK" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
if [ -z "$CHECK_SLUG" ]; then
  echo "Invalid check '$CHECK'. Needs at least one letter or digit (e.g. 7.2)."
  exit 1
fi

mkdir -p conflicts

TS_DISPLAY="$(bash scripts/now.sh)"
TS_FILE="$(bash scripts/now.sh file)"
FILE="conflicts/${TS_FILE}-${CLAIM}-check-${CHECK_SLUG}.md"

if [ -e "$FILE" ]; then
  echo "Conflict file already exists: $FILE"
  exit 1
fi

# Frontmatter is always shell-minted (§I1, §I10): the opening status, repair_side,
# the detected_at stamp, the open-invariant resolved_at: null, and the two links.
# The body is the conflicts/TEMPLATE.md scaffold (everything after its own
# frontmatter block) — a falling-back inline stub keeps the script self-contained.
{
  echo "---"
  echo "status: open"
  echo "repair_side: ${REPAIR}"
  echo "detected_at: ${TS_DISPLAY}"
  echo "resolved_at: null"
  echo "claim: ${CLAIM}"
  echo "check: ${CHECK}"
  echo "---"
  echo ""
  if [ -f conflicts/TEMPLATE.md ]; then
    awk 'BEGIN{fm=0; done=0}
         /^---[[:space:]]*$/ && !done { fm=!fm; if(!fm) done=1; next }
         done { print }' conflicts/TEMPLATE.md
  else
    cat <<'STUB'
# <Short title — what the belief and the artifact disagree about>

## What the belief says
## What the code says
## Why this is a disagreement
## What the skill was attempting
## Suggested resolution paths
## Files involved
STUB
  fi
} > "$FILE"

echo "Opened $FILE"
