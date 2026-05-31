---
name: start
stance: think
when: At the very start of every session, before any other skill — to restore
  context after a cold open (a fresh clone, an overnight pause, a project switch).
reads:
  - STATE.md
  - JOURNAL.md
  - CONTEXT.md
writes: []
runs:
  - make status
halts: none
---

# start

## Purpose

Restore context at the start of a session so the rest of the work inherits a
coherent thread. Memory **triangulates three committed surfaces and trusts none
alone** (§I8): the derived `STATE.md`, the top of the append-only `JOURNAL.md`,
and the live `make status` conflict list. `start` reads all three, reconciles
them, surfaces the open question, and elicits today's focus.

`start` covers **cold-open recovery only**. It does **not** subsume on-demand
`recall` — answering a mid-session "what did we decide about X". `recall` is a
known, scoped fast-follow (a free-form query over a 60-day window, with
confidence labelling, answered in chat only); it is **not built here**, and
`start` does not replace it. The fast-follow trigger is recurring mid-session
"what did we decide about X" friction — *not* "`start` proved too coarse for cold
opens."

## When to use

- At the very start of every session, before any other skill.
- After resuming from a long pause (overnight, a weekend).
- After context-switching between projects and needing to re-orient.

## Procedure

### 0. Load the three memory surfaces + the live conflict list

Read, then reconcile — no single surface is authoritative (§I8):

- **`STATE.md`** — the derived landing page, written by `log` at the last
  session's close. It is a convenience and **may be stale**; treat it as a hint,
  never as truth.
- **`JOURNAL.md`** — read the top (newest-first). The most recent ~3 entries
  drive the summary; the full file is append-only and load-bearing, so consult it
  for any reflexive question. **Nothing here goes stale.**
- **`make status`** — run it for the *live* open-conflict list, recent claims,
  and in-flight specs. This is the ground truth for what is currently disputed;
  nothing depends on a human remembering a conflict exists.
- **`CONTEXT.md`** — skim the term→module/claim map so the session speaks the
  project's registered vocabulary.

Where `STATE.md` and the live `make status` / `JOURNAL.md` disagree, the live
sources win and `STATE.md` is simply out of date (the next `log` will refresh it).

### 1. Handle the cold-open / first-session case

If `JOURNAL.md` holds no real entries (only the bootstrap placeholder
`## YYYY-MM-DD HH:MM (project start)`), skip the summary and say:

> "First session — what are we starting?"

Then go to step 4. Do not improvise this case; the wording above is canonical.

### 2. Summarise the recent thread

In ~3 bullets from the top of `JOURNAL.md`: what was **done**, what was **found**,
what was flagged as **next**. Keep it short — a long summary pushes context out
faster than it helps. With fewer than three entries, summarise what is there.

### 3. Surface the open question

State the most recent entry's `Next:` line (the previous session's intended next
step) **and** name every open conflict from `make status` (each carries a `claim`
and a `repair_side` saying where to look first). These are the live threads the
session most likely picks up.

### 4. Ask the focus, and wait

Ask:

> "What are we working on today?"

`start` is a context-setting gate: do not proceed until the researcher answers,
because the answer determines which skill comes next (`think` to explore, `pin`
to promote a note, `build` to make code correct, a `write` skill to produce
output, or `think` on a `conflicts/` file to adjudicate).

## Error conditions

- **`JOURNAL.md` does not exist.** Halt with: "JOURNAL.md is missing. Run
  `bash scripts/setup.sh` to bootstrap the repo." Do not silently create one — a
  missing journal is a setup problem worth investigating.
- **`JOURNAL.md` has no `# JOURNAL.md — Research Log` heading.** Halt with:
  "JOURNAL.md is malformed. Restore the `# JOURNAL.md — Research Log` heading."
  (`make validate-journal` enforces this.)

## Honest disclaimers

- The recent-entries summary is short by design. Need more? Read `JOURNAL.md`
  directly — it is append-only and complete.
- The "open question" is literally the last `Next:` line; it may be stale (a day,
  a week). If it is plainly no longer relevant, say so and ask for a new direction.
- `STATE.md` is derived and may lag reality. When it conflicts with `make status`
  or the journal, trust the live sources.
