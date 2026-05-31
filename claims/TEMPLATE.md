---
id: C####                  # 'C' + four digits — minted by `make new-claim`; never hand-written (§I1)
status: conjecture         # conjecture | settled | retired (§I10) — no "disputed" state; dispute is a join (§I7)
opened: YYYY-MM-DD HH:MM    # minted via `make now`
touched: YYYY-MM-DD HH:MM   # bumped via `make now` on each revisit
---

# <one-line statement of the belief>

## Statement

<What is claimed, in one or two sentences. State the belief itself — not the plan
to test it (the plan lives in `specs/`).>

## Why

<Why this belief is load-bearing: the *why* of the decision. What leans
on it, and what the alternative was if it turns out wrong.>

## Checks

Each row's **Class** is `contract` (red ⇒ the code is wrong; the build halts) or
`probe` (red ⇒ the belief may be wrong; it opens a conflict and routes to `think`,
but does not halt). Disputedness is never stored here — it is derived by asking the
conflict register which open conflicts point at this claim (§I7).

| Check | Class | Status | Notes |
|---|---|---|---|
| <what must hold for the code to be correct> | contract | — | |
| <what we expect to observe if the belief holds> | probe | — | |

## Attachments

<Links to the spec in `specs/`, figures, or derived data in `data/derived/` that
back this claim. None yet.>
