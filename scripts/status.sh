#!/bin/bash
# scripts/status.sh — the dashboard.
#
# Three registers: open conflicts, recent claims, in-flight specs. `start` reads
# the same open-conflict list, so nothing depends on a human remembering a
# dispute exists.
#
# Always exits 0 — empty registers print a clean line, not an error. Anything
# under an /archived/ path is excluded, as is each TEMPLATE.md.

skip() {
  # True (skip) for archived paths and TEMPLATE.md files.
  case "$1" in
    */archived/*) return 0 ;;
  esac
  [ "$(basename "$1")" = "TEMPLATE.md" ]
}

echo "Repository status"
echo "================="
echo ""

# --- Open conflicts ---------------------------------------------------------
echo "Open conflicts:"
found=0
for f in conflicts/*.md; do
  [ -e "$f" ] || continue
  skip "$f" && continue
  if grep -Eq '^status:[[:space:]]*open[[:space:]]*$' "$f" 2>/dev/null; then
    echo "  - $f"
    found=1
  fi
done
[ "$found" -eq 0 ] && echo "  nothing open"
echo ""

# --- Recent claims (newest first, capped) -----------------------------------
echo "Recent claims:"
found=0
for f in $(ls -t claims/C*.md 2>/dev/null | head -10); do
  skip "$f" && continue
  id=$(grep -E '^id:' "$f" | head -1 | sed 's/^id:[[:space:]]*//')
  st=$(grep -E '^status:' "$f" | head -1 | sed 's/^status:[[:space:]]*//')
  echo "  - ${id} (${st}) — $f"
  found=1
done
[ "$found" -eq 0 ] && echo "  none yet"
echo ""

# --- In-flight specs --------------------------------------------------------
echo "In-flight specs:"
found=0
for f in specs/*.md; do
  [ -e "$f" ] || continue
  skip "$f" && continue
  echo "  - $f"
  found=1
done
[ "$found" -eq 0 ] && echo "  none"

exit 0
