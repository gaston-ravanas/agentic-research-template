# AGENTS.md — the universal agent entry point

Read this file first, every session. It is the one committed home for how an
agent behaves in this repository. The behaviour itself lives in the nine
`skills/*/SKILL.md` files (canonical and committed); this page is the map and
the single standing rule that no skill restates.

## Supported agents

| Agent | How it finds this repo's instructions |
|---|---|
| Any `AGENTS.md`-aware agent | reads this file; skills at `.agents/skills/` |
| Claude Code | `CLAUDE.md` imports this file; skills at `.claude/skills/` |
| OpenCode | skills at `.opencode/skills/` |
| Windsurf | `.windsurfrules` points here |

The `.claude/`, `.opencode/`, `.agents/` adapters are **generated** — see
[One source of truth](#one-source-of-truth).

## Start here

1. Read the top of `JOURNAL.md` (the most recent entries — it is newest-first;
   read further down only for a reflexive, whole-history question).
2. Run `/start`.

`/start` triangulates `STATE.md`, the top of `JOURNAL.md`, and the live
`make status` conflict list — it trusts none of them alone.

## The nine skills

Three stances. **think** — loose work where being wrong is free. **build** —
the one expensive mode, where wrong code costs, and the only stance that halts.
**write** — outward material generated from committed state. There is no skill
literally named `write`.

| Skill | Stance | When to reach for it |
|---|---|---|
| `/start` | think | Session opener — restore context after a cold open, before anything else. |
| `/think` | think | Cheap exploration: reason, distill a paper, interpret a result; also the **one** path that adjudicates a `conflicts/` file. |
| `/pin` | think | Promote a hardened note into a load-bearing claim — with checks and registered vocabulary. |
| `/log` | think | Session closer — append what happened to `JOURNAL.md` so the next `/start` inherits the thread. |
| `/build` | build | A claim has checks but no green code: write the spec into `specs/`, one RED test per check, then `src/` until the **contract** checks pass. |
| `/critique` | build | Adversarial read of a single artifact (a claim, a paper section, any text) before something leans on it. Chat-only; writes nothing. |
| `/draft` | write | Turn settled claims and their attached figures into paper prose under `paper/sections/`. |
| `/brief` | write | Generate a digest or a handoff from committed state, for a person or a future session. |
| `/intake` | write | Land outside material (a paper, a dataset, a reference) with provenance, quarantined until deliberately promoted. |

## The one guardrail — when to stop and ask

There is exactly **one** place the agent stops and asks, and it is stated here,
once — never as a field in a skill file. A rule copied across nine files is a
rule that drifts across nine files.

Being wrong is cheap in `think` and `write`: explore, draft, and brief without
gating. The single expensive mode is `build`, and the guardrail is its halt:

> When a **contract** check is still red after one honest fix cycle, **stop the
> line.** Do not force the test green and do not edit the test to pass. Open a
> conflict — `make open-conflict claim=C#### check=<name> repair_side=program` —
> and hand the decision back to the user.

This is the only halt in the suite. Beyond it, use ordinary judgement before any
action that is expensive to undo or that reaches outside the repo (a commit, a
push, a destructive overwrite): say what you are about to do and let the user
confirm. Everything cheap and recoverable, you may just do.

## Checks: contract vs probe

Every check on a claim carries a **class**, and the class decides whether red
halts:

- **contract** — an algorithmic promise. Red means the *code* is wrong; `build`
  halts (the guardrail above).
- **probe** — a theoretical expectation. Red means the *belief* may be wrong. A
  red probe **always** opens a conflict (`repair_side: argument` or `undecided`)
  and routes to `/think` — but it never blocks the build. Opening that conflict
  is your obligation when you see a red probe; the shell does not detect it for
  you.

## Disagreement: one lifecycle

One disagreement is one file per dispute in `conflicts/`. There is exactly one
path through it:

```
make open-conflict  →  /think (run on the conflicts/ file)  →  make close-conflict
```

`make status` lists every open conflict and `/start` reads the same list, so
nothing depends on a human remembering a dispute exists. `make rename` drift
routes into this same lifecycle (a `repair_side: argument` conflict); it never
invents a second kind of alarm. Whether a claim is "disputed" is **derived** by
asking the register which open conflicts point at it — it is never a stored field
on the claim.

## The deterministic shell mints; the model reads

The `Makefile` and `scripts/` are the only things that mint timestamps, ids, and
commits. Never invent a timestamp or a claim id — read `make now` and
`make new-claim`. Never call a test runner, linter, formatter, or compiler
directly — always go through `make` (`make test`, `make lint`, `make paper`, …).
Commits use a **closed** twelve-scope vocabulary so the git log stays queryable:

```
claim:  conflict:  src:  test:  spec:  paper:
note:   brief:     intake:  archive:  template:  log:
```

## LANGUAGE

The committed `.env.example` carries the repo's language; a git-ignored `.env`
(made by `make setup`) overrides it locally:

```
LANGUAGE=python          # python | r built in (case-insensitive)
```

The shell reads `LANGUAGE` to pick only the test/lint/format/install runner
behind `make` — every other target is language-agnostic. The Makefile and CI both
resolve `.env` first, then `.env.example`, so a fresh clone and CI honour the
committed default without anyone committing a `.env`. A language with no built-in
adapter degrades gracefully (only the runner targets ask you to add one — a single
adapter block in the `Makefile`); the rest of the shell keeps working. Never
assume a language — let the shell adapt. Model selection happens in your agent's
UI, not in this repo: pick a strong model for `/think`, `/critique`, and
`/draft`; a cheaper one is fine for mechanical `/build` sessions.

## One source of truth

`skills/*/SKILL.md` is **canonical and committed**. Edits go there. This file
(`AGENTS.md`) is the committed entry point every agent reads first. The per-tool
pointers — `CLAUDE.md` and `.windsurfrules` — are
committed but **tiny**: they only say "read `AGENTS.md` and `skills/`."

The invariant `§I` laws that the skills and scripts cite — the contract for
*changing* the template — live in `CONTRIBUTING.md`. `GUIDE.md` is the narrative
*why*; `CONTRIBUTING.md` is the law sheet.

The full adapters `.claude/`, `.opencode/`, `.agents/` are **generated by
`make sync` and git-ignored**. A file never committed cannot drift in history, so
there is no drift to police. After editing any skill, run `make sync`. The
pre-commit sync check only **warns** if a local adapter is stale — a stale
git-ignored copy is a local inconvenience, not a repository fault.
