---
name: intake
stance: write
when: Outside material enters the repo — a paper PDF, a dataset, a
  reference doc. Land it safely with provenance, quarantined in inbox/ (or
  data/raw/ for a dataset) until it is deliberately promoted. The skill contract
  around `make intake`.
reads:
  - inbox/
  - data/raw/
  - CONTEXT.md
writes:
  - inbox/
  - data/raw/
runs:
  - make intake
  - make now
halts: none
---

# intake

## Purpose

`intake` is the one safe doorway for **outside material**. Anything that
originates outside the repo — a downloaded paper, a raw dataset, a reference
document — enters through `make intake`, which stamps **provenance** (the source
plus a `make now` timestamp the model never invents, §I1) and lands it
**quarantined**:

- general material → `inbox/<YYYY-MM-DD>-<name>.md`
- a raw dataset → `data/raw/<name>/` (with a `PROVENANCE.md` record)

It is the **write** stance and has **no halt** (§I10). It **lands and quarantines**;
it never promotes.

### Quarantine until deliberately promoted

Landed material is **inert**: nothing in the repo may depend on it until it is
*deliberately* promoted into the working belief structure —

- into a **claim** (`pin` → `make new-claim`),
- into a **note** (`think`), or
- into a **derived dataset** under `data/derived/` (`build`).

Promotion is a separate, deliberate act under another skill. `intake` never
promotes on its own; raw material staying raw is the safety property.

## When to use

- A PDF, dataset, or reference document needs to enter the repo with a traceable
  origin.
- Not for material the repo produced itself (already inside the lifecycle), and not
  for promoting already-landed material (that is `pin`/`think`/`build`).

## Step 0 — Load context (scoped — §I4)

- Glance at `inbox/` and `data/raw/` to see what has already landed (avoid a
  duplicate; pick a clear `<name>`).
- Read `CONTEXT.md` if the material relates to registered vocabulary.

Read only what you need — never the whole repo (§I4).

## Procedure

### 1. Run `make intake`

```
make intake name=<slug> source=<origin> [dataset=1]
```

- `name` — a lowercase-hyphen slug; **required** (no name → the shell refuses).
- `source` — where it came from (URL, citation, person). Provenance is the point;
  without it the shell records a placeholder and **warns**.
- `dataset=1` — land a raw dataset under `data/raw/<name>/` instead of a doc in
  `inbox/`.

The deterministic shell does the rest: it stamps `source` + `make now` into the
landed record, writes the **quarantine note**, and **commits under `intake:`**
(§I1, §commit-scopes). The model supplies the slug and source; it never mints the
timestamp and never hand-writes the commit (§I1).

### 2. Drop the actual material alongside the record

For a dataset, place the raw files under the created `data/raw/<name>/` directory
next to its `PROVENANCE.md`. For an inbox item, the landed `.md` is the provenance
card — attach or reference the material from it. Fill in the card's **What came
in** and **Why it was brought in** sections.

### 3. Leave it quarantined

Stop here. `intake`'s job ends at a committed, provenance-stamped, quarantined
record. Promotion (claim / note / derived dataset) is a later, deliberate step
under another skill.

## Conventions

- **Provenance is shell-minted** (§I1): `make intake` stamps the timestamp and
  commits; the model never invents either.
- The commit scope is **`intake:`** for both `inbox/` and `data/raw/` material
  (§commit-scopes). `intake` adds the `make intake` target and edits no
  earlier layer's target (§I2).
- **Approval discipline** lives once in `AGENTS.md` (§I5); `intake` does not restate
  it.

## Honest disclaimers

- A quarantine is a discipline, not a sandbox: the shell does not technically
  prevent something from depending on `inbox/` material. The guarantee is that the
  material is *marked* inert and traceable; honouring it is authoring discipline.
- Material with no `source` still lands, but its provenance is a placeholder — a
  brief built on un-sourced inputs is one you cannot fully defend later.
- `intake` never promotes. If you find yourself building belief inside `inbox/`,
  promote it out first (`pin`/`think`/`build`).
