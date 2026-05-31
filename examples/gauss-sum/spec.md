---
claim: C0001
modules: [gauss_sum]
---

# Spec — C0001 gauss-sum (the plan)

The build plan behind claim `C0001`. The **claim** is the belief; this **spec** is
the plan for realizing it in code. A real spec lives in `specs/` and is committed
under the `spec:` scope, kept out of the claim's git lineage so the claim's history
stays about the *belief*, not the build-plan churn (§I11). This copy is colocated
with the example only so the walkthrough is self-contained.

## Approach

One pure function, `gauss_sum(n) -> int`, returning `n * (n + 1) // 2`. Integer
floor division is exact here because exactly one of `n`, `n + 1` is even. Negative
`n` is out of the identity's domain, so it raises `ValueError`. No dependencies
beyond the standard library — the example must run on a bare checkout.

## Checks → tests

Each row of the claim's Checks table becomes exactly one test. The check **class**
is copied from the claim (it lives on the claim's row, §I3); it is not re-decided
here.

| Check | Class | Realizing test | Approach | Tolerance |
|---|---|---|---|---|
| 1.1 | contract | `test_gauss_sum.py::test_contract_closed_form_equals_naive_loop` | 200 random `n` in `[0, 10000]`, compare to `sum(range(1, n+1))` | exact |
| 1.2 | probe | `test_gauss_sum.py::test_probe_ratio_approaches_one_half` | `n ∈ {10³,10⁴,10⁵,10⁶}`, compare `gauss_sum(n)/n²` to `0.5` | `1e-3` |

## Order of work (the `build` procedure, §build)

1. Write the spec (this file).
2. Generate one **RED** test per check — both the `contract` and the `probe` row —
   in `tests/` (here, colocated). A test that was never red proves nothing.
3. Write the module until every **contract** check is green.
4. Triage by class: a red `contract` halts after one honest fix cycle
   (`repair_side: program`); a red `probe` opens a conflict (`repair_side:
   argument`) and routes to `/think`, but does not halt. Both checks ship green, so
   neither path fires here — see `README.md` for how each *would*.

## Risk

Trivial: closed-form integer arithmetic. The interesting part of this example is
not the math — it is that it exercises **both** check classes and drives the
conflict lifecycle end to end.
