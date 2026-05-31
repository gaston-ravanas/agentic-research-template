#!/bin/bash
# scripts/new-claim.sh — mint a claim (§I1, §I10).
#
# Invocation (via Makefile):
#   make new-claim name=<slug>
#
# Mints the next sequential C#### id (by scanning claims/ for the highest),
# stamps `opened`/`touched` from scripts/now.sh, and scaffolds
#   claims/C####-<slug>.md
# with valid claim frontmatter. The body comes from claims/TEMPLATE.md when it
# exists; until then a minimal inline
# stub keeps this script self-contained.
#
# This scaffolds only — it does not commit. The claim is filled in (Statement,
# Why, Checks) before it is worth committing under the `claim:` scope.

set -e

NAME="$1"

if [ -z "$NAME" ]; then
  echo "Usage: make new-claim name=<slug>"
  exit 1
fi

# Validate slug: lowercase letters, digits, and hyphens only.
if ! echo "$NAME" | grep -qE '^[a-z0-9][a-z0-9-]*$'; then
  echo "Invalid name '$NAME'. Use lowercase letters, digits, and hyphens only."
  exit 1
fi

mkdir -p claims

# Find the highest existing C#### id, then increment.
max=0
for f in claims/C[0-9][0-9][0-9][0-9]-*.md; do
  [ -e "$f" ] || continue
  n=$(basename "$f" | sed -E 's/^C([0-9]{4})-.*/\1/')
  n=$((10#$n))
  [ "$n" -gt "$max" ] && max=$n
done
ID=$(printf 'C%04d' $((max + 1)))

TS="$(bash scripts/now.sh)"
FILE="claims/${ID}-${NAME}.md"

if [ -e "$FILE" ]; then
  echo "File already exists: $FILE"
  exit 1
fi

# Frontmatter is always shell-minted (§I10): id, the opening status, and the two
# timestamps. The body is layered on top.
{
  echo "---"
  echo "id: ${ID}"
  echo "status: conjecture"
  echo "opened: ${TS}"
  echo "touched: ${TS}"
  echo "---"
  echo ""
  if [ -f claims/TEMPLATE.md ]; then
    # Take the template body: everything after its own frontmatter block.
    awk 'BEGIN{fm=0; done=0}
         /^---[[:space:]]*$/ && !done { fm=!fm; if(!fm) done=1; next }
         done { print }' claims/TEMPLATE.md
  else
    cat <<'STUB'
# <one-line statement of the belief>

## Statement
<What is claimed, in one or two sentences.>

## Why
<Why this belief is load-bearing — the decision's *why*.>

## Checks
| Check | Class | Status | Notes |
|---|---|---|---|
| <what must hold> | contract | — | |
| <what we expect> | probe | — | |

## Attachments
<Links to specs/, figures, or data/derived — none yet.>
STUB
  fi
} > "$FILE"

echo "Created $FILE"
