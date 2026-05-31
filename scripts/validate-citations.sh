#!/usr/bin/env bash
# scripts/validate-citations.sh — blocking pre-flight before make paper.
#
# Hyphenated so `make validate` discovers it via the scripts/validate-*.sh
# glob (§I2); `make validate-citations` is the by-name wrapper.
#
# Scans paper/sections/*.typ for @citation-key references and verifies each
# appears in paper/bibliography.bib. Also flags any [!! missing @key] markers
# left by the `draft` skill. Passes cleanly when there is no sections content;
# exits non-zero on any missing key or leftover marker.

set -e

BIB_FILE="paper/bibliography.bib"
SECTIONS_DIR="paper/sections"

if [ ! -f "$BIB_FILE" ]; then
  echo "ERROR: $BIB_FILE not found."
  exit 1
fi

if [ ! -d "$SECTIONS_DIR" ]; then
  echo "No sections directory found — skipping citation validation."
  exit 0
fi

# Detect [!! missing @key] markers — these must never reach compilation.
MISSING_MARKERS=$(grep -rho '\[!! missing @[^]]*\]' "$SECTIONS_DIR" 2>/dev/null | sort -u)

# Extract @key references from sections, EXCLUDING anything inside
# [!! missing @key] markers (reported separately): strip the markers first,
# then pull the keys.
#
# The grep class allows '.' and ':' because BibTeX keys may contain them
# internally (e.g. @Knuth:1997). But Typst does NOT treat a TRAILING '.' or ':'
# as part of the label — `@smith2023.` at the end of a sentence references key
# `smith2023`, with the period as ordinary punctuation. So strip any trailing
# '.'/':' to match what Typst actually resolves; otherwise a citation that ends a
# sentence (the common case) would be mis-read as a different, "missing" key.
USED_KEYS=$(find "$SECTIONS_DIR" -name "*.typ" -exec cat {} \; 2>/dev/null \
            | sed 's/\[!! missing @[^]]*\]//g' \
            | grep -ho '@[a-zA-Z][a-zA-Z0-9_:.-]*' \
            | sed 's/^@//' \
            | sed 's/[.:]*$//' \
            | sort -u)

# Extract every key defined in bibliography.bib (commented %-lines never match
# the ^@ anchor, so the stub's example entry is ignored).
DEFINED_KEYS=$(grep -hoE '^@[a-zA-Z]+\{[^,]+' "$BIB_FILE" 2>/dev/null \
               | sed 's/^@[a-zA-Z]*{//' \
               | sort -u)

# Find used keys not defined in the bib.
MISSING_KEYS=""
if [ -n "$USED_KEYS" ]; then
  MISSING_KEYS=$(echo "$USED_KEYS" | while read -r key; do
    if [ -n "$key" ] && ! echo "$DEFINED_KEYS" | grep -qx "$key"; then
      echo "$key"
    fi
  done)
fi

ERRORS=0

if [ -n "$MISSING_MARKERS" ]; then
  echo "Citation markers from the draft skill still present in sections:"
  echo "$MISSING_MARKERS" | sed 's/^/  /'
  echo "  → Add the missing keys to $BIB_FILE and remove the markers."
  ERRORS=1
fi

if [ -n "$MISSING_KEYS" ]; then
  if [ "$ERRORS" -eq 1 ]; then echo ""; fi
  echo "Citation keys used in sections but missing from $BIB_FILE:"
  echo "$MISSING_KEYS" | sed 's/^/  - @/'
  ERRORS=1
fi

if [ "$ERRORS" -eq 1 ]; then
  echo ""
  echo "make paper aborted. Fix the issues above and try again."
  exit 1
fi

echo "Citation validation passed."
exit 0
