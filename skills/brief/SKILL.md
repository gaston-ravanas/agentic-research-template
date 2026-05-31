---
name: brief
stance: write
when: Outward communication generated from committed state — a digest of
  where things stand, or a handoff to another person or a future session. Reads the
  committed surfaces, writes one document; the recipient is a content line, not a
  forked format.
reads:
  - STATE.md
  - JOURNAL.md
  - claims/
  - conflicts/
  - CONTEXT.md
writes:
  - docs/briefs/
  - docs/handoffs/
runs:
  - make now
  - make status
halts: none
---

# brief

## Purpose

`brief` generates outward communication **from committed state** — never from
memory or a hand-typed summary. It reads the surfaces that already record
where things stand and produces one document:

- a **digest** into `docs/briefs/` — a snapshot of where the work is, for a reader
  who needs the state of play; or
- a **handoff** into `docs/handoffs/` — the same generation pointed at a different
  home, for the next person or session picking the work up (a handoff is a
  `brief` pointed at `docs/handoffs/`).

It is the **write** stance and has **no halt** (§I10).

### The recipient is a content line, not a forked format

There is **one** `brief` skill, not one per audience. Who the brief is *for* —
advisor, collaborator, future-you, a review committee — is a **content line inside
the document** that shapes tone and emphasis. It is **not** a format flag and
**not** a separate code path. Digest-vs-handoff is only a choice of **home**
(`docs/briefs/` vs `docs/handoffs/`); the recipient never forks the skill.

## When to use

- Someone needs a readable snapshot of where the project stands → a digest.
- You are handing the work to another person or a future session → a handoff.
- Not for exploration (`think`), and not for the paper itself (`draft`).

## Step 0 — Load context (scoped — §I4)

Read the committed state — and trust no single surface alone (§I8):

- `STATE.md` — the derived snapshot (may be stale; a convenience).
- the top of `JOURNAL.md` — the load-bearing, newest-first log.
- `make status` — the **live** open-conflict list, the source of truth for what is
  disputed (disputedness is a join, never a stored field, §I7).
- `claims/` for the beliefs in scope, `CONTEXT.md` for the vocabulary.

Triangulate; do not paraphrase one surface and call it the state (§I8). Read only
what the brief covers — never the whole repo (§I4).

## Procedure

### 1. Decide digest vs handoff (home only)

Same generation, two homes: a **digest** lands in `docs/briefs/`; a **handoff**
lands in `docs/handoffs/`. This is the only branch — the recipient is handled in
content, below.

### 2. Generate from state

Draft the document from what you read in Step 0: where the work stands, the
load-bearing claims, the **open conflicts** (`make status`), and the next steps.
Open with a **`For:` line** naming the recipient — that line, not a flag, is what
tunes tone and emphasis. Every state assertion must trace to a committed surface;
`brief` reports state, it does not invent it.

### 3. Name and write the file

Date the filename from `make now` and **strip the `HH:MM`** — named documents are
date-only (§I1; never hand-type the date):

- digest → `docs/briefs/YYYY-MM-DD-<name>.md`
- handoff → `docs/handoffs/YYYY-MM-DD-<name>.md`

Draft in chat, show it, write on approval.

### 4. Commit under the `brief:` scope (§commit-scopes)

Both digests and handoffs under `docs/` commit under **`brief:`** — e.g.
`brief: YYYY-MM-DD-<name>`.

**Auto-commit guard (strict).** Before committing, run `git status --porcelain`.
If unstaged files exist outside the document you just wrote, list them and ask the
researcher to commit, ignore, or cancel — never sweep unrelated work into a
`brief:` commit, and never abort with a bare message.

## Conventions

- **Approval discipline** lives once in `AGENTS.md` (§I5); `brief` does not restate
  it. `r` in an approval gate means "discuss first," never a silent rewrite.
- `brief` adds **no** Makefile target — it *calls* `make now` and `make status`.
- Disputedness comes from `make status` (the conflict-register join), never from a
  field stored on a claim (§I7).

## Honest disclaimers

- A brief is a snapshot of **committed** state. Uncommitted work in the tree will
  not appear — that is intentional; `brief` reports what is on the record.
- `STATE.md` can be stale; that is why `brief` triangulates it against `JOURNAL.md`
  and the live `make status` rather than trusting it alone (§I8).
- The recipient is a content line. If you want a second `brief` variant per
  audience, write a different `For:` line instead — do not fork the skill.
