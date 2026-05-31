#!/bin/bash
# scripts/archive.sh — retire a file without deleting its history.
#
# Invocation (via Makefile):
#   make archive file=<path>
#
# Moves <path> to <parent>/archived/<basename> and commits under the `archive:`
# scope (§commit-scopes). `make status` excludes anything under /archived/, so
# the file drops off the dashboard while its git history survives the move.

set -e

FILE="$1"

if [ -z "$FILE" ]; then
  echo "Usage: make archive file=<path>"
  exit 1
fi

if [ ! -e "$FILE" ]; then
  echo "No such file: $FILE"
  exit 1
fi

PARENT="$(dirname "$FILE")"
BASE="$(basename "$FILE")"
DEST_DIR="${PARENT}/archived"
DEST="${DEST_DIR}/${BASE}"

if [ -e "$DEST" ]; then
  echo "Already archived: $DEST"
  exit 1
fi

mkdir -p "$DEST_DIR"

# Preserve history when the file is tracked; fall back to a plain move otherwise.
if git ls-files --error-unmatch "$FILE" >/dev/null 2>&1; then
  git mv "$FILE" "$DEST"
else
  mv "$FILE" "$DEST"
  git add -- "$DEST" 2>/dev/null || true
fi

TS="$(bash scripts/now.sh)"

# Commit only the two affected paths so unrelated staged work is left alone.
if git rev-parse --git-dir >/dev/null 2>&1; then
  git add -- "$FILE" "$DEST" 2>/dev/null || true
  if git commit -m "archive: ${BASE} (${TS})" -- "$FILE" "$DEST" >/dev/null 2>&1; then
    echo "Archived $FILE → $DEST and committed (archive:)."
  else
    echo "Archived $FILE → $DEST (nothing to commit)."
  fi
else
  echo "Archived $FILE → $DEST (not a git repository; not committed)."
fi
