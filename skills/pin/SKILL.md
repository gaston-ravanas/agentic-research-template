---
name: pin
stance: think
when: A loose note has hardened into something code will depend on — promote it
  from exploration to a load-bearing claim, with checks and registered vocabulary.
reads:
  - notes/
  - CONTEXT.md
  - claims/
writes:
  - claims/
  - CONTEXT.md
runs:
  - make new-claim
  - make now
halts: none
---

# pin

## Purpose

`pin` is the think → build hinge. When a note in `notes/` has stopped being a
loose idea and become a belief that code will lean on, `pin` promotes it to a
**claim**: it mints the claim through the shell, turns the note into a Statement
and a Why, proposes the checks that will police it, and registers any new
vocabulary in `CONTEXT.md`. After `pin`, the claim is ready for `build` to write a
spec, tests, and code.

`pin` does **not** write the spec or the tests or any `src/` — that is `build`.
`pin` mints the *belief* and its *checks*, nothing downstream.

## When to use

- A scratch note has hardened into something correctness-critical.
- You are about to enter `build` and need a claim for the code to point at.
- A decision needs a durable, queryable home with its *why* attached.

## Step 0 — Load context

- Re-read the note(s) being promoted (`notes/...`).
- Read `CONTEXT.md`'s term→module/claim map (so you reuse, not duplicate, terms).
- Skim `claims/` (or `make status`) so you do not mint a near-duplicate of an
  existing claim.

## Procedure

### 1. Mint the claim through the shell (§I1)

Run:

```
make new-claim name=<slug>
```

The shell mints the next sequential `C####` id and stamps `opened`/`touched` from
`make now`. **Never hand-write an id or a timestamp** — the deterministic shell is
the only thing that mints them. `make new-claim` *scaffolds only*; it does not
commit.

### 2. Fill the Statement and the Why

- **Statement** — the belief itself, in one or two sentences. State the belief,
  not the plan to test it (the plan lives in `specs/`, written later by `build`).
- **Why** — why this belief is load-bearing: what leans on it, and what the
  alternative was if it turns out wrong. This is the *why* the claim
  exists to preserve.

### 3. Propose the checks (the two axes start here)

Fill the Checks table. Each row carries a **Class** (§I10, §I3):

- **`contract`** — red ⇒ the *code* is wrong; `build` halts on it.
- **`probe`** — red ⇒ the *belief* may be wrong; it always opens a conflict and
  routes to `think`, but does **not** halt the build.

Propose at least one of each where it makes sense. Disputedness is **never** stored
on the claim — whether it is currently disputed is derived by asking the conflict
register which open conflicts point at it (§I7). There is no `disputed` status.

### 4. Register new terms in `CONTEXT.md`

Any term the claim introduces gets a row in the term→module/claim map, pointing at
this claim id — so a registered term always resolves to the one place that defines
it, keeping vocabulary consistent and self-correcting. If a term looks like it
collides with an existing one, raise it rather than registering a duplicate.

### 5. Commit under the `claim:` scope

`make new-claim` only scaffolded the file; `pin` commits the *filled* claim plus
the updated `CONTEXT.md` under **`claim:`** (§commit-scopes) — e.g.
`claim: C#### <slug>`.

**Auto-commit guard (strict).** Before committing, run `git status --porcelain`.
If unstaged files exist outside the claim and `CONTEXT.md`, list them and ask the
researcher to commit them first, ignore them, or cancel — never sweep unrelated
work into a `claim:` commit.

## Honest disclaimers

- Promoting a note does not delete it; the note stays in `notes/` as the
  exploration trail. The claim is the load-bearing version.
- Proposed checks are a starting contract, not the final test suite. `build`
  turns them into RED tests and the spec; reality (a red probe) may later send the
  claim back through `think` for adjudication (§I3).
