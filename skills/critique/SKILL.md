---
name: critique
stance: build
when: An artifact needs an adversarial read before something leans on it — a claim
  before code is built on it, a paper section before it ships, any text worth
  pressure-testing. Chat-only review; writes no file.
reads:
  - the single file handed in as the argument (e.g. claims/*.md,
    paper/sections/*.typ, or any text file)
writes: []
runs: []
halts: none
---

# critique

## Purpose

`critique` is adversarial review: it reads **one** file and pushes back on it
through **file-type-dispatched persona sets**, where each persona is a *failure-mode
detector* for that kind of artifact. It is **chat-only** — it writes no
file and commits nothing. It catches wrong cheaply, before code
or a paper leans on it.

> `critique` is the lightest-sourced of the nine skills; if it ever proves not to
> earn its place, this is the skill to reconsider. Its contract: file-type dispatch,
> chat-only, writes no file.

## When to use

- Pressure-test a `claims/*.md` Statement/Why before `build` writes code against it.
- Stress a `paper/sections/*.typ` section before it ships outward.
- Get a careful-reader pass on any other text artifact (with the caveat below).

## Step 0 — Load context (the one file — §I4)

Read **only** the file handed in as the argument. `critique` reads nothing else —
not the rest of `claims/`, not the repo. Scoped reads are the discipline here (§I4).

## Procedure

### 1. Pre-flight (in order) — refuse early, before any review

Each check is an **input refusal** (a pre-flight abort), *not* the build halt —
`critique` has no contract halt (§I10). Run them in order and stop at the first
failure:

- **Exists.** If the path does not resolve → refuse:
  `critique: file not found: <path>`.
- **Text, not binary.** Check via the `file` command or an extension allowlist. If
  binary → refuse: `critique: refuses to critique binary file <path>`.
- **Under 200 KB.** If larger → refuse:
  `critique: file too large (<size>); narrow scope and re-run`.

### 2. Dispatch on file type

Pick the persona set from the **file type** — this is the dispatch:

- **`claims/*.md` or theory-flavoured markdown** → the **theory** persona set:
  - **skeptic** — is this actually true? where is the load-bearing assumption?
  - **pedant** — are the definitions tight, the terms used consistently?
  - **rival** — what would a competing camp say; what is the strongest objection?
- **`paper/sections/*.typ`** → the **paper-section** persona set:
  - **reader** — is this clear; does the argument land on first read?
  - **reviewer** — would this survive peer review; what gets flagged?
  - **stats cop** — are the quantitative claims actually supported?
- **Anything else** → a **generic** "what would a careful reader push back on?"
  pass, with an **explicit caveat in the output**:
  *"this file type doesn't have a tuned persona set yet."*

Personas are **failure-mode detectors, not character sketches**:
each scans for a specific way *this kind of file* tends to be wrong. They are
starting sets — refine them per project.

### 3. Per-persona output (chat only)

For each persona, write a one-sentence framing then **2–4 bullets** of concrete
pushback:

```
<persona> — <its framing in one sentence>
- <critique 1>
- <critique 2>
```

### 4. Synthesis line

Close with **1–2 sentences across the personas**: the single most important thing
to fix, and whether the artifact is ready to lean on or needs another pass.

## Conventions

- **Chat-only.** `critique` writes **no file** and has **no commit scope** — there
  is nothing to commit (§commit-scopes lists only committing actions).
- **Approval discipline** lives once in `AGENTS.md` (§I5); `critique` does not
  restate it, and since it writes nothing there is no write to gate.

## Honest disclaimers

- The persona sets are starting points, not a fixed rubric; the generic pass is
  explicitly weaker and says so in its own output.
- `critique` only reads the one file it was handed — it will miss problems that
  live in context it was not given. It is a cheap pass, not a guarantee.
- A clean `critique` is not a green check. Correctness gating is `build`'s contract
  checks (§I3); `critique` is an adversarial read, not a halt.
