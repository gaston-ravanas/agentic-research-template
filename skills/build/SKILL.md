---
name: build
stance: build
when: A claim exists with checks but no green code yet — write the spec into
  specs/, generate one RED test per check, then write src/ until the contract
  checks pass. This is the one work mode where being wrong is expensive,
  and the only stance with a halt.
reads:
  - claims/
  - CONTEXT.md
  - specs/
writes:
  - specs/
  - tests/
  - src/
  - claims/
runs:
  - make now
  - make new-claim
  - make test
  - make open-conflict
halts: A contract check still red after one honest fix cycle — open a conflict
  with repair_side=program and stop the line (§I3). This is the
  only real halt in the suite (§I10).
---

# build

## Purpose

`build` makes code correct against a belief. It reads a claim, writes a **spec**
into `specs/`, generates a **RED test per check**, then writes `src/` until the
**contract** checks pass. This is the **build**
stance — the one mode where being wrong is expensive, so it is the **only stance
with a halt** (§I10).

Two things make `build` different from the think-stance skills:

- **It can halt.** A contract check still red after one honest fix cycle stops the
  line: `build` opens a `repair_side=program` conflict and **halts** rather than
  grinding on expensive wrongness (§I3).
- **It owns the probe-red obligation.** On *any* red probe, opening a conflict is a
  **non-optional procedure step** — a skill obligation, not a shell gate (§I3).
  The build does not stop for it, but it must not go quiet either.

## When to use

- A claim exists (minted by `pin`), its Checks table is filled, but there is no
  green code behind it yet.
- A conflict resolved under `think` decided "fix the code" — the repair is made
  here, under this stance's discipline.

## Step 0 — Load context (scoped — §I4)

- Read the **claim** being built (`claims/C####-*.md`): its Statement, its Why, and
  every row of the Checks table with its **class** (`contract` | `probe`).
- Read `CONTEXT.md`'s term→module/claim map so the code speaks the project's
  registered vocabulary.
- Read the **spec** once you have written it (step 1).

Read only what you need — never the whole repo. Runtime read-confinement is P2
authoring discipline, not a checked property (§I4); honour it anyway.

## Procedure

### 1. Write the spec into `specs/`

From the claim, write the build plan to `specs/<C####>-<slug>.md`: the approach,
the modules to touch, how each check becomes a test, the order of work. The spec
is the **plan**; the claim is the **belief**.

The spec is deliberately kept **out of the claim's git history** so the claim's
lineage stays about the belief, not the build-plan churn (§I11). Commit the spec
under the **`spec:`** scope (§commit-scopes) — e.g.
`spec: C#### <slug>`.

### 2. Generate one RED test per check (§I10)

Turn each row of the claim's Checks table into a test in `tests/` — **both**
`contract` and `probe` rows. The tests must start **RED** (they fail before any
`src/` exists): a test that was never red proves nothing. Commit under the
**`test:`** scope.

### 3. Write `src/` until the contract checks pass (GREEN)

Implement against the spec. Run `make test` to see the suite. Iterate on `src/`
until every **`contract`** check is green. Commit working increments under the
**`src:`** scope.

### 4. Triage every red check by its class — the two axes (§I3, §I10)

A red check means different things depending on its **class** (the check-class
axis lives on the claim's check row; it answers "do we halt at all?"):

- **`contract` red ⇒ the code is wrong.** Being wrong is expensive here. Fix the
  code (back to step 3) — for **one honest fix cycle**.
- **`probe` red ⇒ the belief may be wrong, not the code.** The build does **not**
  halt; instead it fires the probe-red rule below and continues.

### 5. The probe-red rule — NON-OPTIONAL (§I3)

On **any** red probe, run — as a mandatory procedure step, never skipped:

```
make open-conflict claim=C#### check=<id> repair_side=argument
```

Use `repair_side=argument` when the belief looks like the wrong party, or
`repair_side=undecided` when it is genuinely unclear which side to repair first.
Then **surface it loudly in chat** — name the claim, the check, and the new
conflict file — and **continue the build** (a probe does not halt).

This "a red probe cannot go quiet" guarantee is a **skill-procedure obligation,
not a shell gate**: the shell does not auto-detect a red probe and fire a conflict
(auto-firing from a structured test report is a fast-follow, §I3). If
`build` does not run `make open-conflict` here, nothing else will. No check
asserts a red probe mechanically cannot be missed — this step is the only thing
that keeps it from going quiet.

### 6. The halt — the one halt (§I10)

A **`contract`** check still red after **one honest fix cycle** ends the build:

```
make open-conflict claim=C#### check=<id> repair_side=program
```

Then **stop**. Surface the halt loudly in chat (the claim, the contract check, the
`repair_side=program` conflict). Hand off to `think` on that conflict file (§I3).

"One honest fix cycle" means a real attempt at the code, not a token edit. Once it
is spent and the contract is still red:

- **Do not** keep grinding past the halt — the whole point of the contract class is
  that stopping is correct when being wrong is expensive.
- **Do not** weaken or delete the test to force green.
- **Do not** reclassify the check `contract → probe` to dodge the halt.
  Reclassifying a check is `think`'s adjudication call on the conflict file (§I3),
  never a `build` escape hatch.

### 7. Figure routing — three-way, no `figure` skill

There is **no `figure` skill**. Figures route three ways:

- **(a) claim-attached analysis figure** → produced by the `build` pipeline that
  produced the result; listed in the claim's **Attachments**.
- **(b) static schematic** → committed directly to `paper/figures/`.
- **(c) exploratory / not-yet-durable plot** → `playground/`; promoted into (a)
  when it earns a claim.

The durable non-claim plot is the **(c) → (a)** path: it lives in `playground/`
until the result it shows becomes load-bearing enough to earn a claim, at which
point the claim is minted through the shell (`make new-claim` — §I1, never a
hand-written id) and `build` regenerates the plot as a **claim-attached** figure
recorded in that claim's Attachments. Earning a *belief* claim from a note is
still `pin`'s job; this path is for a *result* a figure has made load-bearing.

### 8. Commit scopes (§commit-scopes)

`build`'s three durable artifacts map to three scopes:

| Artifact | Scope |
|---|---|
| spec written to `specs/` | `spec:` |
| edits to `tests/` | `test:` |
| edits to `src/` | `src:` |

A claim-attached figure recorded in the claim's Attachments rides with the `src:`
commit that produced it. `build` adds **no** Makefile targets — it *calls* the
existing `make now`, `make new-claim`, `make test`, and `make open-conflict`.

**Auto-commit guard (strict).** Before each commit, run `git status --porcelain`.
If unstaged files exist outside the artifact you are committing, list them and ask
the researcher to commit, ignore, or cancel — never sweep unrelated work into a
`src:` / `test:` / `spec:` commit, and never abort with a bare message.

## Conventions

- **Approval discipline** (when to stop and ask before writing) is stated **once**
  in `AGENTS.md` (§I5). `build` does **not** restate it as a frontmatter field — a
  guardrail duplicated across nine skill files is a guardrail that drifts.
- `r` in an approval gate means "let's discuss the change first," never a silent
  rewrite. Approval gates (`y/n/r`) gate **file writes only**, never "ready for the
  next step?".
- The check **class** lives on the claim's check row; the **`repair_side`** lives
  on the conflict (§I3). `build` reads the first and sets the second; it does not
  store disputedness anywhere (§I7).

## Honest disclaimers

- The spec is a plan, not a contract; it is kept out of the claim's git lineage on
  purpose. If the plan changes, the spec changes — the belief does not.
- A halt is not a failure; it is the system working. The contract class exists so
  that being wrong stops the line instead of shipping quietly.
- A probe red routes the *belief* back through `think`, not the code. `build`'s job
  on a probe red is to open the conflict and keep moving, not to adjudicate it.
