---
status: open                    # open | closed (§I10)
repair_side: undecided          # program | argument | undecided — where the NEXT session looks first (§I3)
detected_at: YYYY-MM-DD HH:MM    # minted via `make now`
resolved_at: null               # null iff status: open (§I3); a timestamp once closed
claim: C####                    # the claim this dispute points at (id only)
check: <id>                     # the check row that surfaced it (e.g. 7.2)
---

# <Short title — what the belief and the artifact disagree about>

> One disagreement per file. Lifecycle (§I3): `make open-conflict` → `think` (run
> on this file) → `make close-conflict`. `repair_side` only says where the next
> session looks first — it is not a verdict.

## What the belief says

<Quote or paraphrase the relevant claim (`claims/C####-*.md`) and the check that
fired. Cite the path. 3–6 lines.>

## What the code says

<Quote or paraphrase the relevant `src/`, `tests/`, or output artifact. Cite the
path. 3–6 lines.>

## Why this is a disagreement

<One paragraph: what was expected vs what was found. Be specific — name the claim
id, the check row, the function, or the test that surfaced it.>

## What the skill was attempting

<One sentence: which skill was running and what it was doing when it halted (e.g. a
red `probe`, or `make rename` drift).>

## Suggested resolution paths

<2–4 concrete options the next `think` session can choose from. Examples:>
- <Fix `src/…` so the check passes — the program was wrong (repair_side: program).>
- <Revise the claim or its check — the belief was wrong (repair_side: argument).>
- <Reclassify the check (`contract` ⇄ `probe`) — the halt policy was wrong.>

## Files involved

- <claims/C####-*.md>
- <full path 2>
