# Worked example — `gauss-sum`

A complete, self-contained instance of the system: one **claim**, its **spec**, the
realizing **module**, and one **test per check** — exercising **both** check classes
(`contract` and `probe`) and the full **conflict lifecycle** end to end.

It is deliberately trivial mathematics (the schoolbook Gauss sum) so the example is
about the *machinery*, not the proof. Everything here lives under `examples/`, so
the live registers (`claims/`, `conflicts/`, `src/`, `tests/`) stay pristine for
your own work.

## The files

| File | Role |
|---|---|
| `C0001-gauss-sum.md` | The **claim** — the belief, with a Checks table: one `contract` row, one `probe` row. |
| `spec.md` | The **plan** — how each check becomes a test. (A real spec lives in `specs/` under the `spec:` scope.) |
| `gauss_sum.py` | The **module** — `gauss_sum(n) = n·(n+1)/2`, pure standard library. |
| `test_gauss_sum.py` | The **tests** — one per check row, both passing. |

## Run it

```bash
python3 -m pytest examples/gauss-sum -q
```

Two tests pass. There is no `__init__.py` here on purpose: pytest puts this folder
on `sys.path`, so the test imports the colocated module plainly as `gauss_sum`.

## The two check classes (the heart of the example)

Every check on a claim carries a **class**, and the class — not a human — decides
whether a red result halts the build (§I3, §I10):

### 1.1 — `contract`: the math is the authority, so fix the code

> `gauss_sum(n)` must equal the naive loop `sum(range(1, n+1))`, exactly.

A `contract` is an **algorithmic promise**. If this test went red, the *code* is
wrong — the closed form disagrees with the definition it claims to compute. Under
the `build` stance this **halts the line** after one honest fix cycle:

```bash
make open-conflict claim=C0001 check=1.1 repair_side=program
```

`repair_side: program` says the next session should look at the **code** first. The
build does **not** force the test green, weaken it, or reclassify it to dodge the
halt — stopping is the correct move when being wrong is expensive.

### 1.2 — `probe`: the math is on trial, so open a conflict

> `gauss_sum(n) / n²` should approach `0.5` as `n` grows large.

A `probe` is a **theoretical expectation**. If this test went red, it is the
*belief* that is suspect, not necessarily the code — maybe the asymptotic is wrong,
or stated with the wrong constant, or the tolerance is unrealistic. A red probe
**never halts the build**, but it must never go quiet either. Opening a conflict is
a **non-optional `build` procedure step** (a skill obligation, not a shell gate —
§I3):

```bash
make open-conflict claim=C0001 check=1.2 repair_side=argument
```

`repair_side: argument` says the next session should look at the **belief** first
(use `undecided` when it is genuinely unclear which side to repair).

## The conflict lifecycle, end to end

There is exactly one path through a disagreement (§I3):

```
make open-conflict   →   /think (run on the conflicts/ file)   →   make close-conflict
```

Suppose check 1.2 had gone red. The walk would be:

1. **Open.** `build` runs `make open-conflict claim=C0001 check=1.2
   repair_side=argument`. The shell mints `conflicts/<timestamp>-C0001-check-1-2.md`
   with `status: open` and `resolved_at: null` (the iff constraint), links the claim
   and the check, and does **not** commit — opening a dispute is non-committal.
2. **Surface.** `make status` lists the open conflict, and so does `/start` on the
   next session. Nothing depends on a human remembering the dispute exists. `build`
   also names it loudly in chat, then **continues** (a probe does not halt).
3. **Adjudicate.** `/think` runs *on the conflict file* and chooses among the
   resolution paths: revise the belief or its tolerance (the argument was wrong);
   fix the code (it really was a code bug after all — flip `repair_side` to
   `program`); or reclassify the check `contract ⇄ probe` (the halt policy was
   wrong). Adjudication is `/think`'s call, never a `build` escape hatch.
4. **Close.** `make close-conflict file=conflicts/<…>.md` flips `status` to
   `closed`, stamps a real `resolved_at` (restoring the iff), and commits under the
   **`conflict:`** scope. The register is settled.

Note what is *not* here: there is no `disputed` status on the claim. Whether `C0001`
is disputed is **derived** by asking the conflict register which open conflicts
point at it (§I7) — a status you must remember to flip is a status that lies.

## Why it ships green

Both checks pass as committed, so `make validate` stays green and CI is honest. The
probe-red path above is therefore **narrated**, not shipped red — a red probe is a
skill obligation, and shipping a permanently-red test would break CI and contradict
that obligation (§I3). During the template's construction, a capstone check
exercised this mechanism end to end — driving `make open-conflict` / `make status` /
`make close-conflict` against this very claim on a throwaway conflict, then removing
it so the live register stayed pristine.
