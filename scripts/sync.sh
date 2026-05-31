#!/bin/bash
# scripts/sync.sh — regenerate the git-ignored agent adapters from skills/.
#
# skills/*/SKILL.md is the one source of truth (§I6). This script
# copies it outward to the three adapter paths some tools want to discover:
#
#   .claude/skills/    — Claude Code
#   .opencode/skills/  — OpenCode
#   .agents/skills/    — convention path for any AGENTS.md-aware agent
#
# All three are git-ignored: a file never committed cannot drift in
# history, so there is no drift to police. Edits go in skills/; this script
# regenerates the adapters on demand (`make sync`; setup.sh also calls it).
#
# Each target is wiped and repopulated so deletions in skills/ propagate
# cleanly. Every copied SKILL.md gets a do-not-edit header prepended so anyone
# who opens an adapter copy knows where the real file is.

set -e

SOURCE_DIR="skills"
TARGETS=(".claude/skills" ".opencode/skills" ".agents/skills")

HEADER='<!-- AUTO-SYNCED from skills/ — do not edit. Run `make sync` after editing the canonical skill. -->'

if [ ! -d "$SOURCE_DIR" ]; then
  echo "ERROR: $SOURCE_DIR not found — nothing to sync."
  exit 1
fi

for target in "${TARGETS[@]}"; do
  # Wipe and recreate so deletions in skills/ propagate cleanly.
  rm -rf "$target"
  mkdir -p "$target"

  # Walk every file under skills/ and copy it to the target. Markdown files
  # (SKILL.md) get the header prepended; anything else is copied verbatim.
  find "$SOURCE_DIR" -type f | while read -r src; do
    rel="${src#"$SOURCE_DIR"/}"
    dst="$target/$rel"
    mkdir -p "$(dirname "$dst")"
    case "$src" in
      *.md)
        {
          echo "$HEADER"
          echo ""
          cat "$src"
        } > "$dst"
        ;;
      *)
        cp "$src" "$dst"
        ;;
    esac
  done

  echo "Synced skills/ -> $target/"
done
