#!/usr/bin/env bash
# scripts/validate-frontmatter.sh — BLOCKING structural validator for the two
# shell-owned schemas (§I10): the claim and the conflict.
#
#   claims/*.md     — id (C####), status ∈ {conjecture,settled,retired},
#                     opened/touched (YYYY-MM-DD HH:MM).  No 'disputed' status:
#                     disputedness is a join, never a field (§I7).
#   conflicts/*.md  — status ∈ {open,closed}, repair_side ∈
#                     {program,argument,undecided}, detected_at (ts),
#                     resolved_at (ts | null), claim (C####), check.
#                     `status: open` ⇔ `resolved_at: null` — the iff constraint (§I3).
#
# Both TEMPLATE.md files are skipped (they document the schema, they do not obey
# it). An empty / missing directory passes. Errors are line-prefixed
#   <file>:<line>: <problem>; <suggested fix>
# and the script exits 1 if any file is malformed, 0 otherwise.
#
# Pure bash + grep/sed/awk. Discovered and run by `make validate` via the
# scripts/validate-*.sh glob (§I2); also reachable as `make validate-frontmatter`.

ERRORS=0
TS_REGEX='^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$'

err(){ echo "$1" >&2; ERRORS=1; }

# Print the first frontmatter block (between the first two '---' lines) as
# "<lineno>:<content>" rows, so every field keeps its true line number.
frontmatter(){
  awk '
    BEGIN { count=0; in_fm=0 }
    /^---[[:space:]]*$/ {
      count++
      if (count==1) { in_fm=1; next }
      if (count==2) { in_fm=0; exit }
    }
    in_fm { print NR ":" $0 }
  ' "$1"
}

field_line(){ echo "$1" | grep -E "^[0-9]+:$2:" | head -1; }    # the "<n>:name: value" row
line_no(){ echo "$1" | cut -d: -f1; }                            # leading line number
field_val(){ echo "$1" | sed -E "s/^[0-9]+:$2:[[:space:]]*//"; } # value after "name:"

validate_claim(){
  local f="$1" FM idl statusl openedl touchedl n v
  FM="$(frontmatter "$f")"
  if [ -z "$FM" ]; then
    err "$f:1: missing frontmatter; expected a '---' delimited YAML block at the top (mint a claim with \`make new-claim\`)"
    return
  fi

  idl="$(field_line "$FM" id)"
  statusl="$(field_line "$FM" status)"
  openedl="$(field_line "$FM" opened)"
  touchedl="$(field_line "$FM" touched)"

  if [ -z "$idl" ]; then
    err "$f:1: missing required field 'id'; add 'id: C####' (\`make new-claim\` mints it)"
  else
    n="$(line_no "$idl")"; v="$(field_val "$idl" id)"
    echo "$v" | grep -qE '^C[0-9]{4}$' || err "$f:$n: invalid id '$v'; expected 'C' followed by exactly four digits (e.g. C0007)"
  fi

  if [ -z "$statusl" ]; then
    err "$f:1: missing required field 'status'; add 'status: conjecture' (one of conjecture|settled|retired)"
  else
    n="$(line_no "$statusl")"; v="$(field_val "$statusl" status)"
    case "$v" in
      conjecture|settled|retired) ;;
      *) err "$f:$n: invalid status '$v'; must be one of conjecture|settled|retired (no 'disputed' state — dispute is a join, §I7)" ;;
    esac
  fi

  if [ -z "$openedl" ]; then
    err "$f:1: missing required field 'opened'; add 'opened: YYYY-MM-DD HH:MM' (from \`make now\`)"
  else
    n="$(line_no "$openedl")"; v="$(field_val "$openedl" opened)"
    echo "$v" | grep -qE "$TS_REGEX" || err "$f:$n: invalid opened '$v'; expected 'YYYY-MM-DD HH:MM' (use \`make now\`)"
  fi

  if [ -z "$touchedl" ]; then
    err "$f:1: missing required field 'touched'; add 'touched: YYYY-MM-DD HH:MM' (from \`make now\`)"
  else
    n="$(line_no "$touchedl")"; v="$(field_val "$touchedl" touched)"
    echo "$v" | grep -qE "$TS_REGEX" || err "$f:$n: invalid touched '$v'; expected 'YYYY-MM-DD HH:MM' (use \`make now\`)"
  fi
}

validate_conflict(){
  local f="$1" FM statusl repairl detl resl claiml checkl n v
  local status_val="" resolved_val="" res_line=1
  FM="$(frontmatter "$f")"
  if [ -z "$FM" ]; then
    err "$f:1: missing frontmatter; expected a '---' delimited YAML block at the top (open one with \`make open-conflict\`)"
    return
  fi

  statusl="$(field_line "$FM" status)"
  repairl="$(field_line "$FM" repair_side)"
  detl="$(field_line "$FM" detected_at)"
  resl="$(field_line "$FM" resolved_at)"
  claiml="$(field_line "$FM" claim)"
  checkl="$(field_line "$FM" check)"

  if [ -z "$statusl" ]; then
    err "$f:1: missing required field 'status'; add 'status: open' (one of open|closed)"
  else
    n="$(line_no "$statusl")"; status_val="$(field_val "$statusl" status)"
    case "$status_val" in
      open|closed) ;;
      *) err "$f:$n: invalid status '$status_val'; must be 'open' or 'closed'" ;;
    esac
  fi

  if [ -z "$repairl" ]; then
    err "$f:1: missing required field 'repair_side'; add 'repair_side: undecided' (one of program|argument|undecided)"
  else
    n="$(line_no "$repairl")"; v="$(field_val "$repairl" repair_side)"
    case "$v" in
      program|argument|undecided) ;;
      *) err "$f:$n: invalid repair_side '$v'; must be one of program|argument|undecided (§I3)" ;;
    esac
  fi

  if [ -z "$detl" ]; then
    err "$f:1: missing required field 'detected_at'; add 'detected_at: YYYY-MM-DD HH:MM' (from \`make now\`)"
  else
    n="$(line_no "$detl")"; v="$(field_val "$detl" detected_at)"
    echo "$v" | grep -qE "$TS_REGEX" || err "$f:$n: invalid detected_at '$v'; expected 'YYYY-MM-DD HH:MM' (use \`make now\`)"
  fi

  if [ -z "$resl" ]; then
    err "$f:1: missing required field 'resolved_at'; add 'resolved_at: null' while open (a timestamp once closed)"
  else
    res_line="$(line_no "$resl")"; resolved_val="$(field_val "$resl" resolved_at)"
    if [ "$resolved_val" != "null" ] && ! echo "$resolved_val" | grep -qE "$TS_REGEX"; then
      err "$f:$res_line: invalid resolved_at '$resolved_val'; expected 'YYYY-MM-DD HH:MM' or 'null'"
    fi
  fi

  if [ -z "$claiml" ]; then
    err "$f:1: missing required field 'claim'; add 'claim: C####' (the disputed claim)"
  else
    n="$(line_no "$claiml")"; v="$(field_val "$claiml" claim)"
    echo "$v" | grep -qE '^C[0-9]{4}$' || err "$f:$n: invalid claim '$v'; expected 'C' followed by four digits (e.g. C0007)"
  fi

  if [ -z "$checkl" ]; then
    err "$f:1: missing required field 'check'; add 'check: <id>' (the check row that surfaced the dispute)"
  else
    n="$(line_no "$checkl")"; v="$(field_val "$checkl" check)"
    [ -n "$v" ] || err "$f:$n: empty check; name the check row that surfaced the dispute (e.g. 7.2)"
  fi

  # The iff constraint (§I3): status:open ⇔ resolved_at:null.
  if [ -n "$status_val" ]; then
    if [ "$status_val" = "open" ] && [ "$resolved_val" != "null" ] && [ -n "$resolved_val" ]; then
      err "$f:$res_line: resolved_at must be 'null' when status is 'open' (got '$resolved_val') — §I3"
    fi
    if [ "$status_val" = "closed" ] && [ "$resolved_val" = "null" ]; then
      err "$f:$res_line: resolved_at must be a timestamp when status is 'closed' (got 'null'); run \`make close-conflict\` — §I3"
    fi
  fi
}

validate_dir(){
  local dir="$1" kind="$2" f
  [ -d "$dir" ] || return 0
  for f in "$dir"/*.md; do
    [ -e "$f" ] || continue                              # empty dir: glob stays literal
    [ "$(basename "$f")" = "TEMPLATE.md" ] && continue   # the schema doc, not an instance
    if [ "$kind" = "claim" ]; then validate_claim "$f"; else validate_conflict "$f"; fi
  done
}

validate_dir claims claim
validate_dir conflicts conflict

if [ "$ERRORS" -ne 0 ]; then
  echo "validate-frontmatter: FAILED — fix the file(s) above." >&2
  exit 1
fi
echo "validate-frontmatter: claims/ and conflicts/ OK."
exit 0
