#!/bin/bash
# scripts/now.sh — single source of truth for timestamps (§I1).
#
# Two outputs, one source. Never let the model generate a timestamp; skills
# always call this through `make now` or `make now-filename`.
#
#   make now           → 'YYYY-MM-DD HH:MM' (display: claim/conflict frontmatter,
#                                            journal headings, etc.)
#   make now-filename  → 'YYYY-MM-DD-HH-MM' (filename-safe: conflict filenames,
#                                            and anything that lands in a path)

if [ "$1" = "file" ]; then
  date '+%Y-%m-%d-%H-%M'
else
  date '+%Y-%m-%d %H:%M'
fi
