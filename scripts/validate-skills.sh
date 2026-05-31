#!/usr/bin/env bash
# scripts/validate-skills.sh — WARN-ONLY smell check on SKILL.md `reads:` (§I4).
#
# §I4: every SKILL.md carries a `reads:` list. This checker verifies `reads:` is
# PRESENT and LIST-SHAPED, and WARNS (never blocks) when it is absent or names the
# repo root / a top-level catch-all (the "whole-repo smell"). Runtime
# read-confinement is authoring discipline, NOT a checkable property: this
# script never claims a skill read only what it declared.
#
# Warn-only by construction — it ALWAYS exits 0 (§I2), so `make validate`'s glob
# never blocks on it. Passes vacuously while skills/ holds no SKILL.md (true now;
# the skills land in PRDs 05–07).

warn(){ echo "validate-skills: WARN $1" >&2; }

found=0
for f in skills/*/SKILL.md; do
  [ -e "$f" ] || continue
  found=1

  FM=$(awk '
    BEGIN { count=0; in_fm=0 }
    /^---[[:space:]]*$/ { count++; if (count==1){in_fm=1;next} if (count==2){in_fm=0;exit} }
    in_fm { print }
  ' "$f")

  if [ -z "$FM" ]; then
    warn "$f: no frontmatter block; expected '---' delimited YAML with a 'reads:' list (§I4)"
    continue
  fi

  if ! echo "$FM" | grep -qE '^reads:'; then
    warn "$f: missing 'reads:'; declare the paths this skill reads as a list (§I4)"
    continue
  fi

  inline=$(echo "$FM" | sed -nE 's/^reads:[[:space:]]*//p' | head -1)
  if echo "$inline" | grep -qE '^\[.*\]$'; then
    body="$inline"; listshaped=1                          # inline form: reads: [a, b]
  elif [ -n "$inline" ]; then
    body="$inline"; listshaped=0                          # a bare scalar — not a list
  else                                                    # block form: '- item' rows
    body=$(echo "$FM" | awk '
      /^reads:[[:space:]]*$/ { f=1; next }
      f && /^[[:space:]]*-[[:space:]]*/ { print; next }
      f && /^[^[:space:]-]/ { f=0 }
    ')
    [ -n "$body" ] && listshaped=1 || listshaped=0
  fi

  if [ "$listshaped" -ne 1 ]; then
    warn "$f: 'reads:' is not list-shaped; use a YAML list (e.g. 'reads:' then '- path/') (§I4)"
    continue
  fi

  # Whole-repo smell: any entry naming the repo root or a top-level catch-all.
  smell=0
  for tok in $(echo "$body" | tr '[],' '   '); do
    [ "$tok" = "-" ] && continue
    tok="${tok%\"}"; tok="${tok#\"}"
    tok="${tok%\'}"; tok="${tok#\'}"
    case "$tok" in
      .|./|/|"*"|"**"|"./*"|repo|repository) smell=1 ;;
    esac
  done
  [ "$smell" -eq 1 ] && warn "$f: 'reads:' names the repo root / a whole-repo catch-all — declare specific paths, not the whole tree (§I4)"
done

if [ "$found" -eq 0 ]; then
  echo "validate-skills: no SKILL.md under skills/ yet — nothing to check (warn-only, §I4)."
fi

# Warn-only: never block. Always succeed (§I2, §I4).
exit 0
