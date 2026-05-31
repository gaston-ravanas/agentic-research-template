#!/usr/bin/env bash
# scripts/rename.sh — word-boundary, cross-file identifier rename (§I3,
# §commit-scopes). There is no theory/ here, so the belief side is claims/.
#
# Invocation (via Makefile):
#   make rename old=X new=Y [NO_STAGE=1]
#
# Two sides, one lifecycle:
#
#   - PROGRAM side (src/, tests/): the rename is applied in place, word-boundary
#     aware, POSIX-portably (awk + mktemp + mv — never `sed -i`; BSD and GNU sed
#     disagree). The durable artifact is the edited source, so the rename's own
#     commit is `src:` (§commit-scopes). Touched files are staged
#     atomically unless NO_STAGE=1; making the commit is left to the user.
#
#   - BELIEF side (claims/): a claim is never silently reworded to match a code
#     rename — rewriting a belief is a judgment call, not a mechanical propagation.
#     Instead, if the OLD term still lives in a claim AFTER the source rename (the
#     drift), this routes that drift into the ONE disagreement lifecycle (§I3) via
#     `make open-conflict … repair_side=argument`, pointing the next `think`
#     session at the belief. It never invents a second alarm.
#
# Non-interactive by design (it runs under `make`, unattended in the pipeline).
# NO_STAGE=1 is the safety valve; git keeps the staging reversible.
#
# Pure bash + awk/grep. No language runtime required.

set -u

OLD="${1:-}"
NEW="${2:-}"
NO_STAGE="${3:-}"

if [ -z "$OLD" ] || [ -z "$NEW" ]; then
  echo "Usage: make rename old=X new=Y [NO_STAGE=1]"
  exit 1
fi
if [ "$OLD" = "$NEW" ]; then
  echo "old and new are identical ('$OLD'); nothing to rename."
  exit 1
fi

# Word-boundary replacement, POSIX-portable. awk has no \b, so boundaries are
# tested by hand: a hit counts only when neither neighbour is an identifier char
# ([A-Za-z0-9_]). index()/substr() treat OLD/NEW literally — no regex injection,
# and scanning the original string while advancing past each match means an OLD
# that is a substring of NEW (foo → foobar) never re-matches or loops.
# OLD/NEW arrive via the environment (not -v) so awk never reinterprets a
# backslash in the values.
WB_AWK='
function wbreplace(s, old, rep,    out, idx, before, after, oldlen) {
  out = ""; oldlen = length(old)
  while ((idx = index(s, old)) > 0) {
    before = (idx > 1) ? substr(s, idx - 1, 1) : ""
    after  = substr(s, idx + oldlen, 1)
    if (before ~ /[A-Za-z0-9_]/ || after ~ /[A-Za-z0-9_]/) {
      out = out substr(s, 1, idx + oldlen - 1)   # sub-word: keep it, advance past
    } else {
      out = out substr(s, 1, idx - 1) rep         # whole word: replace
    }
    s = substr(s, idx + oldlen)
  }
  return out s
}
'

# Exit 0 iff OLD occurs as a whole word anywhere in file $1.
word_present() {
  OLD="$OLD" awk '
    BEGIN { old = ENVIRON["OLD"]; oldlen = length(old); found = 0 }
    {
      s = $0
      while ((idx = index(s, old)) > 0) {
        before = (idx > 1) ? substr(s, idx - 1, 1) : ""
        after  = substr(s, idx + oldlen, 1)
        if (before !~ /[A-Za-z0-9_]/ && after !~ /[A-Za-z0-9_]/) { found = 1; exit }
        s = substr(s, idx + oldlen)
      }
    }
    END { exit found ? 0 : 1 }
  ' "$1"
}

TOUCHED="$(mktemp)"
trap 'rm -f "$TOUCHED"' EXIT

echo "rename: '$OLD' → '$NEW'"
echo ""

# --- PROGRAM side: edit src/ and tests/ in place -----------------------------
echo "Program side (src/, tests/):"
program_hits=0
for dir in src tests; do
  [ -d "$dir" ] || continue
  # grep -F pre-filters to files holding the literal substring; the awk pass then
  # applies the precise word-boundary replacement (a no-op when every match was
  # sub-word). A here-doc (not a pipe) keeps the loop in this shell so counters and
  # the TOUCHED accumulator persist. `-I` skips binary files (e.g. compiled
  # __pycache__/*.pyc bytecode) and `--exclude-dir` skips the cache dir outright —
  # without them the scan would rewrite bytecode as text and then fail to stage it
  # (it is git-ignored), polluting the run with spurious hits and git warnings.
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    tmp="$(mktemp)"
    OLD="$OLD" NEW="$NEW" awk "$WB_AWK"'
      BEGIN { old = ENVIRON["OLD"]; new = ENVIRON["NEW"] }
      { print wbreplace($0, old, new) }
    ' "$f" > "$tmp"
    if cmp -s "$f" "$tmp"; then
      rm -f "$tmp"
    else
      mv "$tmp" "$f"
      printf '%s\n' "$f" >> "$TOUCHED"
      echo "  renamed: $f"
      program_hits=1
    fi
  done <<EOF
$(grep -rlIF --exclude-dir=__pycache__ -- "$OLD" "$dir" 2>/dev/null)
EOF
done
[ "$program_hits" -eq 0 ] && echo "  (no whole-word occurrences)"
echo ""

# --- BELIEF side: scan claims/, route drift into the ONE lifecycle (§I3) ------
echo "Belief side (claims/):"
drift_hits=0
if [ -d claims ]; then
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    [ "$(basename "$f")" = "TEMPLATE.md" ] && continue
    word_present "$f" || continue        # refine grep -F substring to a real word
    cid="$(grep -E '^id:[[:space:]]*C[0-9]{4}' "$f" 2>/dev/null | head -1 \
            | sed -E 's/^id:[[:space:]]*//; s/[[:space:]].*//')"
    [ -n "$cid" ] || cid="$(basename "$f" | sed -E 's/^(C[0-9]{4}).*/\1/')"
    echo "  drift: $f still uses '$OLD' (claim $cid)"
    if make open-conflict claim="$cid" check=rename-drift repair_side=argument \
         </dev/null >/dev/null 2>&1; then
      echo "         → opened a drift conflict (repair_side: argument)"
      drift_hits=1
    else
      echo "         → could not open a drift conflict for claim '$cid' (open it by hand)"
    fi
  done <<EOF
$(grep -rlIF --exclude-dir=__pycache__ -- "$OLD" claims 2>/dev/null)
EOF
fi
[ "$drift_hits" -eq 0 ] && echo "  (no surviving '$OLD' in claims/ — belief and program agree)"
echo ""

# --- Staging: atomic, program side only (the conflict carries its own scope) --
if [ -s "$TOUCHED" ]; then
  n="$(wc -l < "$TOUCHED" | tr -d ' ')"
  if [ -n "$NO_STAGE" ]; then
    echo "NO_STAGE=1: leaving $n edited file(s) unstaged. Review, then stage and"
    echo "commit them under the 'src:' scope."
  elif git rev-parse --git-dir >/dev/null 2>&1; then
    while IFS= read -r f; do git add -- "$f"; done < "$TOUCHED"
    echo "Staged $n edited file(s) atomically. Commit under 'src:', e.g.:"
    echo "  git commit -m \"src: rename $OLD → $NEW\""
  else
    echo "Edited $n file(s) (not a git repository; nothing staged)."
  fi
else
  echo "No source files changed."
fi
