#!/bin/sh
# Pre-commit hook — guarding is scoped, not blanket (§I9).
#
#   - The cheap structural validators (the scripts/validate-*.sh glob) ALWAYS
#     run, each independently, so one failure never masks the next.
#   - `make test` and `make lint` are heavy, so they run ONLY when src/ or
#     tests/ is staged — gating a prose-only commit on the test suite would be
#     guarding a cheap, recoverable thing.
#
# Bypass with `git commit --no-verify` — this disables ALL of the above at once,
# not just tests. State explicitly what you are skipping in the journal entry
# that records the bypass.

staged=$(git diff --cached --name-only --diff-filter=ACM)

rc=0

# Cheap structural validators — always, independently. Warn-only validators
# self-exit 0 (§I2), so only genuine failures set rc.
for v in scripts/validate-*.sh; do
  [ -e "$v" ] || continue
  echo "── $v"
  bash "$v" || rc=1
done

# Heavy checks — only when code is staged (§I9).
if printf '%s\n' "$staged" | grep -Eq '^(src|tests)/'; then
  echo "staged src/ or tests/ → running test + lint"
  make test || rc=1
  make lint || rc=1
else
  echo "no staged src/ or tests/ → skipping test + lint (§I9)"
fi

if [ "$rc" -ne 0 ]; then
  echo ""
  echo "BLOCKED: pre-commit validation failed. Run \`make validate\` for details."
  exit 1
fi
