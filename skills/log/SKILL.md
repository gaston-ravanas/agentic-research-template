---
name: log
stance: think
when: The close of every session, after the last meaningful piece of work — to
  capture what happened so the next session's `start` inherits a coherent thread.
reads:
  - JOURNAL.md
  - STATE.md
writes:
  - JOURNAL.md
  - STATE.md
runs:
  - make now
halts: none
---

# log

## Purpose

`log` closes the session. It appends one entry to `JOURNAL.md` and rewrites the
derived `STATE.md`, so the next `start` has the context it needs. `JOURNAL.md` is
the append-only, newest-first, **load-bearing** memory surface — nothing ever
rewrites a past entry, which is precisely why it cannot go stale (§I8).
`STATE.md` is the **derived** convenience landing page; it is allowed to be stale
and is rebuilt here from scratch.

## When to use

- At the end of every session, after the last meaningful work.
- Before switching to a different line of work within a long sitting.

## Procedure

### 1. Get the timestamp from the shell (§I1)

Run `make now` for the display-format timestamp (`YYYY-MM-DD HH:MM`). **Never
generate a timestamp yourself.**

### 2. Review the session

Skim what was discussed, decided, or produced. Identify the **single most
important next action** — that line is what the next `start` leans on.

### 3. Draft the `JOURNAL.md` entry — exactly this template

```
## YYYY-MM-DD HH:MM

**Did**: [1–3 lines]
**Found**: [1–3 lines]
**Stuck on**: [1 line]
**Next**: [1 line — the single most important next action]
**Refs**: [files touched, papers read, claims/conflicts touched]
```

Substitute the timestamp from step 1 into the heading. The template is fixed and
short by design: if a session produced something that does not fit these five
fields, that is a signal it deserves its own artifact (a note, a claim), not a
longer entry.

### 4. Show the draft and ask approval

> "Approve this journal entry? [y/n/r]"

`y/n/r` here gates a file write — its only legitimate use. On `r`, ask what to
change before redrafting; never silently rewrite. On `n`, confirm before
discarding ("your session won't appear in `JOURNAL.md` and the next `start` will
skip it"); treat anything short of an explicit "yes, discard" as keep drafting.

### 5. Prepend to `JOURNAL.md` — never append, never rewrite

Insert the approved entry immediately **after** the `# JOURNAL.md — Research Log`
heading, above all existing entries (newest-first). Never edit an entry above it.
`make validate-journal` enforces the heading, the entry format, and newest-first
order.

### 6. Rewrite the derived `STATE.md`

Regenerate the landing page from the current state: **Aim**, **Open question**,
**Key files**, **Open conflicts** (point at `make status` for the live list), and
**Next move** (mirror this entry's `Next:`). `STATE.md` is derived and may go
stale before the next `log` — `start` triangulates it against `JOURNAL.md` and
`make status` and trusts none alone (§I8), so it is a convenience, not a contract.

### 7. Surface unstaged changes — do **not** gate

Run `git status --porcelain`. If unstaged files exist outside `JOURNAL.md` and
`STATE.md`, list them:

> "Note: unstaged changes outside JOURNAL.md / STATE.md:
> - path/to/file1
> - path/to/file2
>
> Proceeding with JOURNAL.md + STATE.md only. Commit the others separately if
> needed."

Then proceed with the memory commit alone. **Do not block.** `log` is the one
skill whose guard is softened to a surface-and-proceed (every other artifact skill
keeps the strict guard) — closing a session must never be held hostage by an
unrelated dirty file.

### 8. Commit under the `log:` scope

Commit `JOURNAL.md` + `STATE.md` together under **`log:`** — the twelfth scope
(§commit-scopes) — e.g. `log: YYYY-MM-DD HH:MM` (the same timestamp from step 1). No
`journal:` scope exists; memory commits are `log:`.

## Error conditions

- **`JOURNAL.md` does not exist.** Halt with: "JOURNAL.md is missing. Restore it
  from the template or git history before running `log`." Do not silently create
  one — a missing journal usually means a setup problem.
- **The `# JOURNAL.md — Research Log` heading is missing.** Halt with: "JOURNAL.md
  has no top-level heading — cannot determine the insertion point. Restore the
  `# JOURNAL.md — Research Log` heading and re-run `log`."
- **No changes to commit after writing.** If `git status --porcelain` is empty
  after the write, something went wrong with the write — re-check before raising.

## Honest disclaimers

- The entry is the salient outcome, not a session transcript. `start` reads only
  the top few entries; verbose entries push context out faster than they help.
- `STATE.md` is a derived snapshot. It can lag the moment it is written; that is by
  design, which is why it is never the sole source `start` trusts.
