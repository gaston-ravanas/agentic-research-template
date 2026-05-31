#!/usr/bin/env bash
# scripts/intake.sh — land outside material safely, with provenance (§I1).
#
# Invocation (via Makefile):
#   make intake name=<slug> [source=<origin>] [dataset=1]
#
# Outside material enters the repo through exactly here. The deterministic shell
# stamps provenance — the source plus a `make now` timestamp the model never
# invents (§I1) — and lands a quarantine record:
#   inbox/<YYYY-MM-DD>-<slug>.md     (default — a doc, PDF, reference, …)
#   data/raw/<slug>/PROVENANCE.md    (dataset=1 — a raw dataset directory)
# then commits it under the `intake:` scope (§commit-scopes).
#
# QUARANTINE: the landed record says, in the file, that nothing in the repo may
# depend on this material until it is DELIBERATELY promoted — into a claim
# (`pin`/`make new-claim`), a note (`think`), or a derived dataset (`build`).
# `intake` only lands and quarantines; it never promotes.
#
# Pure bash + the shell clock (scripts/now.sh). No language runtime required.

set -e

NAME="$1"
SOURCE="$2"
DATASET="$3"

if [ -z "$NAME" ]; then
  echo "Usage: make intake name=<slug> [source=<origin>] [dataset=1]"
  exit 1
fi

# Validate slug: lowercase letters, digits, and hyphens only (matches new-claim).
if ! printf '%s' "$NAME" | grep -qE '^[a-z0-9][a-z0-9-]*$'; then
  echo "Invalid name '$NAME'. Use lowercase letters, digits, and hyphens only."
  exit 1
fi

# Provenance is shell-minted, never model-invented (§I1).
TS="$(bash scripts/now.sh)"
DATE="${TS%% *}"

# Source is the other half of provenance. Record a placeholder and warn if it is
# absent — material with no traceable origin defeats the point of intake.
if [ -z "$SOURCE" ]; then
  SOURCE="<unspecified — fill in the origin>"
  echo "intake: WARN no source given; recording a placeholder. Pass source=<origin> for real provenance." >&2
fi

if [ -n "$DATASET" ]; then
  DIR="data/raw/${NAME}"
  FILE="${DIR}/PROVENANCE.md"
  KIND="raw dataset"
else
  DIR="inbox"
  FILE="inbox/${DATE}-${NAME}.md"
  KIND="inbox material"
fi
mkdir -p "$DIR"

if [ -e "$FILE" ]; then
  echo "File already exists: $FILE"
  exit 1
fi

{
  echo "---"
  echo "source: ${SOURCE}"
  echo "fetched_at: ${TS}"
  echo "status: quarantined"
  echo "---"
  echo ""
  echo "# Intake: ${NAME}"
  echo ""
  echo "- **Source:** ${SOURCE}"
  echo "- **Fetched:** ${TS} (stamped by \`make now\`, §I1 — never hand-typed)"
  echo "- **Landed as:** ${KIND} at \`${FILE}\`"
  echo "- **Status:** quarantined"
  echo ""
  echo "> **QUARANTINE.** Nothing in the repo may depend on this until it"
  echo "> is *deliberately promoted*. Outside material enters here and stays inert;"
  echo "> promote it into a claim (\`pin\` → \`make new-claim\`), a note (\`think\`), or a"
  echo "> derived dataset under \`data/derived/\` (\`build\`). \`intake\` lands and"
  echo "> quarantines — it never promotes."
  echo ""
  echo "## What came in"
  echo "<describe the material — what it is, its format, how much. Replace this line.>"
  echo ""
  echo "## Why it was brought in"
  echo "<the reason this entered the repo, and the likely next step for it.>"
} > "$FILE"

# Stage and commit only this path (scope-clean: never sweep unrelated staged work,
# mirroring close-conflict.sh). The landed record is the durable `intake:` artifact.
git add -- "$FILE"
git commit -m "intake: ${NAME}" -- "$FILE"

echo "Landed $FILE (quarantined, committed under intake:)."
