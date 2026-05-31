#!/bin/bash
# scripts/validate-sync.sh — warn-only staleness check for the agent adapters.
#
# For each file under skills/, verify the three adapter targets (.claude/skills,
# .opencode/skills, .agents/skills) hold an up-to-date copy. Synced .md files
# carry a 2-line header (header + blank), so the comparison strips the first two
# lines before diffing.
#
# WARN-ONLY (§I6, §I2): always exits 0. The adapters are git-ignored,
# so a stale local copy is an inconvenience, not a repository fault — it must
# never block a commit. Self-exiting 0 also means the `make validate` glob
# (scripts/validate-*.sh) never blocks on it. Output goes to stdout so the
# divergence is visible in `make validate` and pre-commit runs.

set -e

SOURCE_DIR="skills"
TARGETS=(".claude/skills" ".opencode/skills" ".agents/skills")
WARNINGS=0

if [ ! -d "$SOURCE_DIR" ]; then
  echo "validate-sync: skills/ not found; skipping."
  exit 0
fi

for src in $(find "$SOURCE_DIR" -type f); do
  rel="${src#"$SOURCE_DIR"/}"
  for target in "${TARGETS[@]}"; do
    dst="$target/$rel"
    if [ ! -d "$target" ]; then
      echo "$target:0: adapter missing; run \`make sync\`"
      WARNINGS=$((WARNINGS + 1))
      break
    fi
    if [ ! -f "$dst" ]; then
      echo "$dst:0: missing (source: $src); run \`make sync\`"
      WARNINGS=$((WARNINGS + 1))
      continue
    fi
    case "$src" in
      *.md)
        # Synced .md has a 2-line header injected. Strip it and diff.
        if ! diff -q <(tail -n +3 "$dst") "$src" >/dev/null 2>&1; then
          echo "$dst:1: differs from $src; run \`make sync\`"
          WARNINGS=$((WARNINGS + 1))
        fi
        ;;
      *)
        if ! diff -q "$dst" "$src" >/dev/null 2>&1; then
          echo "$dst:1: differs from $src; run \`make sync\`"
          WARNINGS=$((WARNINGS + 1))
        fi
        ;;
    esac
  done
done

if [ "$WARNINGS" -eq 0 ]; then
  echo "validate-sync: skills/ in sync with all adapters."
else
  echo ""
  echo "validate-sync: $WARNINGS divergence(s) above. Warn-only — commit proceeds."
fi

exit 0
