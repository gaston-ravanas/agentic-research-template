---
name: think
stance: think
when: Loose exploration where being wrong is free — conversational reasoning,
  reading and distilling a paper, interpreting a result, building intuition before
  anything is pinned. Also the single adjudication path for a conflicts/ file.
reads:
  - JOURNAL.md
  - CONTEXT.md
  - notes/
  - conflicts/
writes:
  - notes/
  - playground/
  - claims/
  - conflicts/
runs:
  - make now
  - make close-conflict
halts: none
---

# think

## Purpose

`think` is the exploration stance: loose, conversational, plain-language work that
carries **no claims, no checks, no obligations** — you can be wrong here for free.
It produces a durable scratch artifact so the thinking survives the
session.

It has **two modes, one skill**:

- **Exploration** (default) — talk an idea through, then leave a note in `notes/`
  or throwaway code in `playground/`.
- **Adjudication** — when handed a `conflicts/` file, `think` switches from
  exploring to *resolving the one disagreement* (§I3). This is the only place a
  conflict is decided.

## When to use

- Early exploration of a concept, a variant, or a half-formed idea.
- Reading and distilling a paper into a literature note.
- Making sense of a result, a figure, or a derived dataset.
- **Resolving a `conflicts/` file** (the adjudication mode below).

## Step 0 — Load context (silently)

- Read the top of `JOURNAL.md` (most recent ~3 entries) for the current thread.
- Read `CONTEXT.md`'s term→module/claim map so you reuse registered vocabulary.

Then determine the mode: **if a `conflicts/` file was handed in → adjudication
(jump to that section). Otherwise → exploration.**

## Exploration mode

### 1. Explore conversationally

Plain language only — ASCII sketches, pseudo-code, concrete examples. Ask
clarifying questions one at a time; do not dump a list. Suggest angles,
counter-examples, and connections back to `CONTEXT.md`. When the researcher uses a
term that is not in `CONTEXT.md`, flag it gently — "You said X — same as
[existing term], or new?" — but do not register it here; registering a term is
`pin`'s job. Continue until the researcher says "done" or equivalent.

### 2. Write the durable artifact

- **Scratch note** (default): `notes/YYYY-MM-DD-<name>.md`. Suggested shape (follow
  the content, do not force it): what we explored / key intuitions / open questions
  / possible next steps / connections to existing files (by path).
- **Throwaway code**: `playground/` — a sketch to feel out an idea, with no claim
  and no test behind it.

Get the date from `make now` and **strip the `HH:MM`** for note filenames (named
documents use date-only). Never invent a timestamp (§I1). Draft in chat, show it,
and write only on approval.

### 3. Commit under the `note:` scope

Both `notes/` prose and committed `playground/` scratch commit under **`note:`**
(§commit-scopes) — e.g. `note: YYYY-MM-DD-<name>`.

**Auto-commit guard (strict).** Before committing, run `git status --porcelain`.
If unstaged files exist outside the artifact you just wrote, list them and ask the
researcher to commit them first, ignore them, or cancel — do not sweep unrelated
work into a `note:` commit, and do not abort with a bare message.

## Adjudication mode (handed a `conflicts/` file — §I3)

There is exactly **one** disagreement lifecycle:

```
make open-conflict  →  think (run on the conflicts/ file)  →  make close-conflict
```

`think` is the middle step. Both entry points — a contract check still red after
one honest fix cycle, and an always-opened probe-red conflict — resolve through
this same path, as does a `make rename` drift conflict. Adjudication has no halt;
it ends by closing the conflict (or by stating, in chat, why it stays open).

### 1. Read the conflict fully

The file follows `conflicts/TEMPLATE.md`. Read every section, especially **What
the belief says**, **What the code says**, and **Suggested resolution paths** —
those are starting options, not a menu you must invent from scratch. Note the
`repair_side` (`program` | `argument` | `undecided`): it only says **where to look
first**, it is not a verdict.

### 2. Decide — exactly one of four outcomes

Discuss with the researcher and settle on one (§I3):

- **Revise the claim's Why** — the belief was underspecified or wrong-as-stated.
  Edit `claims/C####-*.md` (bump `touched` via `make now`).
- **Fix the code** — the program was wrong. Make the edit under the `build`
  stance's discipline (the durable artifact is the edited `src/`, committed `src:`).
- **Reclassify the check** — the halt policy was wrong; flip the check row's
  **Class** `contract ⇄ probe` in the claim's Checks table.
- **Retire the claim** — the belief is abandoned; set its `status: retired`.

### 3. Close the lifecycle

Run `make close-conflict file=conflicts/<name>.md`. The shell stamps
`resolved_at`, flips `status: closed` (restoring the iff, §I3), and commits under
the `conflict:` scope. The closed file plus its commit **is** the audit trail — do
not write a separate resolution log.

If the dispute genuinely cannot be resolved this session, leave it `open` and say
why in chat (still investigating, partial resolution, escalating). Do not leave it
open silently — the explanation is for the next `start` reader, who will see it in
`make status`.

## Conventions

- `r` (revise) means "let's discuss the change first", never a silent rewrite.
- Approval gates (`y/n/r`) gate **file writes only** — never use them to ask
  "ready for the next step?".
- No claims, no checks, no spec, no tests are produced here. Hardening a note into
  a claim is `pin`; writing the spec and tests is `build`.
