# CONTRIBUTING.md — the contract for changing the template

This template is a thing other people adopt, so changing it must be **safe and
routine**. This file is the contract for that: the governing rule, the invariant
laws (`§I*`) the skills and scripts already cite and enforce, the closed
commit-scope vocabulary, and the canonical rosters.

`GUIDE.md` carries the *narrative* — why the template is shaped this way, read
once end to end. This file is the *law sheet* a maintainer works against when
evolving it. Invariant references like `(§I3)` throughout `skills/` and `scripts/`
are **defined here**, in the §I sections below.

> This supersedes the build-time `build/INVARIANTS.md`. That file was one-time
> scaffolding and went away when the build wrapper was removed; the operative laws
> live on here.

---

## The governing rule

> **Every change names the failure it prevents.**

A change proposal states four things: the **friction observed**, the **change
made**, the **failure it prevents**, and its **migration impact**. A change that
cannot name a concrete failure it prevents is ceremony — and this rule exists
precisely to keep ceremony out. It is the same rule that justifies every cut in the
design: each named absence (`§I11`) stays absent because re-adding it would name no
failure.

**The deterministic shell mints; the model reads.** Read `make now` for the clock
and `make new-claim` for ids — never invent a timestamp or an id. Go through `make`
for every runner (`make test` / `lint` / `paper` / `validate`), never the tool
directly. The `Makefile` and `scripts/` are the only things that mint timestamps,
ids, and commits.

**Adding a language** (e.g. `julia`) is a single adapter block in the `Makefile`
plus an optional CI job — see the seam comments there and `GUIDE.md` §6. Nothing
else in the shell is language-specific.

---

## The invariants — the `§I` laws

These are the cross-cutting laws every part of the template honours. They are
stated **once** here; the skills and scripts cite them by anchor and obey.

### §I1 — The shell mints everything stochastic steps consume

The deterministic shell (the `Makefile` and `scripts/`) is the **only** thing that
mints timestamps, ids, and commits. A model never invents a timestamp, a claim id,
or a `detected_at`. Skills read `make now` for the clock and `make new-claim` for
ids. Every stochastic step is wrapped by a deterministic one.

### §I2 — The Makefile is the one shared shell surface; targets append, never edit

The `Makefile` and the `make validate` aggregate are the single surface every change
extends. The Makefile is authored as one canonical shell; a new target **appends its
own section** and never edits a target another section owns — preserving a
forward-only structure inside one file. `make validate` **discovers** its validators
by globbing `scripts/validate-*.sh` and running each independently (collecting exit
codes, never short-circuiting), so a change adds a validator by dropping a script in
`scripts/`, with no edit to the aggregate. Warn-only validators **must exit 0
themselves** so the glob never blocks on them.

### §I3 — One disagreement lifecycle, one register, two axes

There is exactly **one** conflict lifecycle:

```
make open-conflict  →  think (run on the conflicts/ file)  →  make close-conflict
```

- A disagreement is one file per dispute in `conflicts/`. `make status` lists every
  open one; `start` reads the same list. Nothing depends on a human remembering a
  dispute exists.
- **Two axes, two homes:** the **check class** (`contract` | `probe`) lives on the
  check *row* in the claim (does being red halt at all?); **`repair_side`**
  (`program` | `argument` | `undecided`) lives on the *conflict* (where does the
  next session look first?).
- **`make rename` drift routes into this same lifecycle** — it opens a conflict with
  `repair_side: argument`; it never invents a new alarm.
- **probe-red ALWAYS opens a conflict, but this is a skill-procedure obligation,
  NOT a shell gate.** The `build` skill's procedure makes running `make open-conflict
  … repair_side=argument|undecided` a non-optional step on any red probe; the shell
  does not auto-detect a red probe (auto-firing from a structured test report is a
  deferred fast-follow). **No check may assert a red probe mechanically cannot be
  missed.**
- `status: open` ⇔ `resolved_at: null` (the iff constraint, enforced by the
  frontmatter validator).

### §I4 — `reads:` is well-formed-checked and smell-warned, never runtime-enforced

Every `SKILL.md` carries a `reads:` list. The static check verifies `reads:` is
**present and list-shaped**, and **warns (never blocks)** when it is absent or names
the repo root / a top-level catch-all (the "whole-repo smell"). **Runtime
read-confinement is authoring discipline, not a checkable property.** No check claims
to verify a skill read *only* what it declared.

### §I5 — Approval discipline is stated once, in `AGENTS.md`

When the agent must stop and ask before writing is **one** guardrail in `AGENTS.md`.
It is **never** a per-skill frontmatter field. A rule duplicated across nine skill
files is a rule that drifts across nine files.

### §I6 — One source of truth for behaviour; adapters are generated and git-ignored

`skills/*/SKILL.md` is canonical and committed. `AGENTS.md` is the committed entry
point. The per-tool pointers `CLAUDE.md` and `.windsurfrules`
are committed but **tiny** — they say "read `AGENTS.md` and `skills/`," nothing more.
The full adapters `.claude/`, `.opencode/`, `.agents/` are produced by `make sync`
and are **git-ignored**: a file never committed cannot drift in history, so the drift
bug and its validator are *deleted*, not guarded. The pre-commit sync check **warns
only**.

### §I7 — Disputedness is a join, never a stored field

Whether a claim is currently disputed is **derived** by asking the conflict register
which open conflicts point at it. The claim schema has **no `contested` status**. A
status you must remember to flip is a status that lies.

### §I8 — Memory triangulates three committed surfaces; it trusts none alone

Cold-open recovery (`start`) reads `STATE.md` + the top of `JOURNAL.md` + the live
`make status` conflict list, and never trusts one:

- `STATE.md` — **derived**, written by `log`, allowed to be stale. A convenience.
- `JOURNAL.md` — **append-only, newest-first, load-bearing**; nothing rewrites it,
  so it cannot go stale. Heading is exactly `# JOURNAL.md — Research Log`.
- `CONTEXT.md` — the term→module/claim map, written by `pin`.

`start` covers **cold-open only**; it does **not** subsume on-demand `recall` (a
scoped fast-follow, not built in 1.0.0).

### §I9 — Guarding is scoped, not blanket

The pre-commit hook always runs the cheap structural validators (the
`scripts/validate-*.sh` glob); it runs `make test` and `make lint` **only when
`src/` or `tests/` is staged**. Every validator runs independently and surfaces
together; one failure never masks the next. Gating a prose-only commit on the test
suite is guarding a cheap, recoverable thing — forbidden.

### §I10 — Three frontmatter schemas; the schemas are the contracts

Exactly three schemas. The deterministic shell validates the first two; the third is
authoring discipline (`§I4`).

**Claim** (`claims/C####-slug.md`): `id` (`C` + 4 digits), `status`
∈ `{conjecture, settled, retired}`, `opened` and `touched` (`YYYY-MM-DD HH:MM`,
minted by the shell). Body sections: **Statement**, **Why** (the *why* of the
decision), **Checks** (the table; each row carries a check **class**:
`contract` | `probe`), **Attachments**.

**Conflict** (`conflicts/<ts>-<claim>-<check>.md`): `status` ∈ `{open, closed}`,
`repair_side` ∈ `{program, argument, undecided}`, `detected_at` (ts),
`resolved_at` (ts | `null`, `null` iff `open`), `claim` (`C####`), `check`.

**Skill** (`skills/<name>/SKILL.md`): `name`, `stance` ∈ `{think, build, write}`,
`when`, `reads` (list), `writes` (list), `runs` (list), `halts`. Only `build`
carries a real `halts` condition.

### §I11 — Sixteen committed directories; the named absences stay absent

The committed top-level set is exactly sixteen:

```
skills/ claims/ conflicts/ notes/ playground/ src/ tests/ specs/
data/{raw,derived}/ paper/{sections,figures,tables}/ inbox/
docs/{briefs,handoffs,literature}/ scripts/ migrations/ examples/ .github/
```

The generated adapters (`.claude/ .opencode/ .agents/`) are **not** committed and do
**not** count (`§I6`). These cuts stay cut: no `THEORY.md` index (`claims/` *is* the
index), no `config/` (`pyproject` + `.env` suffice), no `results/`/`output/` (a
result is a figure, a table, or a derived dataset), no `docs/adr/` (the *why* already
has four homes). `specs/` holds persisted build plans kept out of the claim's git
history so the claim's lineage stays about the **belief**, not the **plan**.

---

## §commit-scopes — the closed vocabulary is exactly twelve

Commit scopes are a **closed** vocabulary so the git log is itself queryable. Every
committing action maps to exactly one:

```
claim:  conflict:  src:  test:  spec:  paper:
note:   brief:     intake:  archive:  template:  log:
```

| Action / skill / target | Scope |
|---|---|
| `make new-claim`, `pin` (mint/promote a claim) | `claim:` |
| `make open-conflict`, `make close-conflict`, rename-drift conflict | `conflict:` |
| `build` edits to `src/` | `src:` |
| `build` edits to `tests/` | `test:` |
| `build` spec written to `specs/` | `spec:` |
| `draft`, `make paper` artifacts under `paper/` | `paper:` |
| `think` prose to `notes/` (and committed `playground/` scratch) | `note:` |
| `brief` digests/handoffs under `docs/` | `brief:` |
| `intake` material to `inbox/` or `data/raw/` | `intake:` |
| `make archive` | `archive:` |
| `log` (commits `JOURNAL.md` + `STATE.md`) | `log:` |
| **`make rename`** (cross-file identifier edits) | **`src:`** |
| changes to the template's own machinery (Makefile, scripts, skills, docs) | `template:` |

`make rename` commits under `src:` because a rename's durable artifact *is* the
edited source. No `journal:`/`rename:`/`vocab:` scope exists.

## §nine-skills — the canonical roster

Exactly nine skills. There is **no skill literally named `write`**.

| Skill | Stance |
|---|---|
| `start` | think |
| `think` | think |
| `pin` | think |
| `log` | think |
| `build` | build |
| `critique` | build |
| `draft` | write |
| `brief` | write |
| `intake` | write |

`recall`, `figure`, `vocab`/`define`, `spike` are **folded or deferred**, not skills
(see `GUIDE.md` §13 for the deferred fast-follows and why each is held back).

## §nine-needs — the canonical numbering

The nine needs the template exists to serve. Cite these numbers consistently:

1. continuity / cold-open recovery, **including the *why*** of past decisions;
2. exploration stays cheap — no claim-tax until something load-bearing depends on it;
3. theory↔implementation disagreement, **first-class & recoverable**;
4. correctness **gated only where being wrong is expensive**;
5. outward communication is **generated from state**, not hand-assembled;
6. outside material enters safely (quarantine + provenance);
7. vocabulary stays consistent and self-correcting;
8. the repository produces the paper;
9. the template is safe to evolve and adoptable by others.

"Three modes legible" is **not** a tenth need — it is the `think` / `build` / `write`
stances serving #2 (and #1's legibility).
