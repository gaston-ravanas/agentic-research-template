---
name: draft
stance: write
when: A claim (or a set of claims) is settled enough to say outward — turning
  committed beliefs and their attached figures into prose. Section drafting into
  paper/sections/, maintaining the include list in paper/main.typ, wiring in the
  figures attached to the claims it cites. The outward material layer.
reads:
  - claims/
  - paper/sections/
  - paper/main.typ
  - paper/figures/
  - CONTEXT.md
writes:
  - paper/sections/
  - paper/main.typ
runs: []
halts: none
---

# draft

## Purpose

`draft` turns committed belief into outward prose: it writes the paper's sections
into `paper/sections/<name>.typ`, maintains the include list in `paper/main.typ`,
and wires in the figures attached to the claims it cites.
It is the **write** stance — outward-facing material generated from state that is
already committed, never from memory. Like every write- and think-stance skill it
has **no halt**; the one real halt in the suite is `build`'s (§I10).

`draft` folds what earlier designs split into a separate `plan-paper`/outline
skill: **the outline is part of `draft`**, not its own skill. You
outline and you draft in the same stance, against the same `paper/` tree.

> **Figure routing.** The three-way figure routing applies to `draft` —
> claim-attached figures come from the `build` pipeline; static schematics are
> committed to `paper/figures/`; `draft` wires the figures attached to the claims
> it cites and never regenerates them.

## When to use

- A claim is settled and load-bearing enough to state in the paper.
- An outline exists (or needs writing) and sections must be drafted or revised.
- A section needs the figure(s) attached to the claim(s) it cites wired in.

Not for exploration (that is `think`), not for making code correct (`build`), and
not for a digest or handoff to a person (`brief`).

## Step 0 — Load context (scoped — §I4)

- Read the **claims** the section will cite (`claims/C####-*.md`): their Statement,
  their Why, and the **Attachments** — that is where a claim-attached figure is
  recorded.
- Read the current `paper/sections/` and the `paper/main.typ` include list, so you
  extend the outline rather than fork it.
- Read `paper/figures/` for the static schematics already committed.
- Read `CONTEXT.md` so the prose speaks the project's registered vocabulary.

Read only what the section needs — never the whole repo (§I4).

## Procedure

### 1. Outline first (the outline is part of `draft`)

Settle the section structure before prose: which claims this section states, in
what order, and which figure each cite-and-wire step pulls in. The outline lives in
the `paper/` tree — the section files and the `paper/main.typ` include order — not
in a separate skill or a separate plan file.

### 2. Draft the section into `paper/sections/<name>.typ`

Write the prose one section per file. Draft in chat, show it, write on approval.
Each sentence that asserts a result should trace back to a **committed claim** —
`draft` states settled belief, it does not invent it.

### 3. Maintain the include list in `paper/main.typ`

A new section is not real until `paper/main.typ` includes it. When you add a
section file, add its include to `paper/main.typ`'s list and order it to match the
outline; when you remove or rename one, fix the list in the same edit. Compiling
the source is the paper build system's job (`make paper`) — `draft` maintains the
**source**, it does not compile it.

### 4. Cite-and-wire figures — never regenerate

For each claim the section cites, wire in the figure attached to that claim:

- **(a) claim-attached figure** — produced by the `build` pipeline and recorded in
  the claim's **Attachments**. `draft` references it; it **never regenerates** it.
- **(b) static schematic** — committed to `paper/figures/`. `draft` references it.

If a section seems to need a figure that no claim attaches and no schematic
provides, that is a signal the result is not yet load-bearing — earn it a claim
(through `pin`/`build`) first. `draft` does not mint figures; there is no `figure`
skill.

### 5. Commit under the `paper:` scope (§commit-scopes)

`draft`'s artifacts under `paper/` — section files and the `paper/main.typ` include
list — commit under **`paper:`** (the same scope as `make paper` artifacts), e.g.
`paper: <section>`.

**Auto-commit guard (strict).** Before committing, run `git status --porcelain`.
If unstaged files exist outside the section/include edit you are committing, list
them and ask the researcher to commit, ignore, or cancel — never sweep unrelated
work into a `paper:` commit, and never abort with a bare message.

## Conventions

- **Approval discipline** (when to stop and ask before writing) is stated **once**
  in `AGENTS.md` (§I5); `draft` does not restate it as a frontmatter field.
- `r` in an approval gate means "let's discuss the change first," never a silent
  rewrite. Approval gates (`y/n/r`) gate **file writes only**.
- `draft` adds **no** Makefile target. Compilation is the paper build system's
  (`make paper`); `draft` only maintains the Typst source.

## Honest disclaimers

- `draft` states committed belief; it is not where belief is formed. A sentence
  with no claim behind it is a sentence `draft` should not be writing yet.
- `draft` never regenerates a figure. A stale claim-attached figure is
  fixed by re-running the `build` pipeline that owns it, not by redrawing it here.
- The outline is part of `draft`, not a separate artifact — do not look for a
  `plan-paper` skill.
