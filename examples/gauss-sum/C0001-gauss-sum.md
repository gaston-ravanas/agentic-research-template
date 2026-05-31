---
id: C0001
status: settled
opened: 2026-05-31 10:37
touched: 2026-05-31 10:37
---

# The Gauss closed form computes 1+2+...+n in O(1)

## Statement

For every integer `n ≥ 0`, the sum `1 + 2 + … + n` equals the closed form
`n·(n+1)/2`. Computing it that way is exact integer arithmetic in constant time —
no loop over the `n` terms is needed.

## Why

This claim is load-bearing for any downstream result that sums a contiguous range
in a hot path: it lets the code replace an `O(n)` loop with an `O(1)` expression
without changing the answer. The alternative — keeping the naive loop — is correct
but pays a cost we do not need to pay; if the closed form were *wrong*, every such
substitution would silently corrupt a total, so the belief must be checked, not
assumed.

This is the template's one worked example. It is deliberately self-contained under
`examples/` so the live registers (`claims/`, `conflicts/`, `src/`, `tests/`) stay
pristine for an adopter.

## Checks

Each row's **Class** decides whether red halts. `contract` — an algorithmic
promise; red means the *code* is wrong and `build` halts. `probe` — a theoretical
expectation; red means the *belief* may be wrong, so it opens a conflict and routes
to `/think`, but it never halts the build. Disputedness is never stored here; it is
derived by asking the conflict register which open conflicts point at this claim
(§I7).

| Check | Class | Status | Notes |
|---|---|---|---|
| 1.1 — `gauss_sum(n)` equals the naive loop `sum(range(1, n+1))` for random `n` | contract | green | exact integer equality; red ⇒ the code is wrong (the build halts, `repair_side: program`) |
| 1.2 — `gauss_sum(n) / n²` approaches `0.5` as `n` grows large | probe | green | tolerance `1e-3`; red ⇒ the belief may be wrong (opens a conflict, `repair_side: argument`) |

## Attachments

- Spec (the plan): `examples/gauss-sum/spec.md`
- Realizing module: `examples/gauss-sum/gauss_sum.py`
- Tests (one per check): `examples/gauss-sum/test_gauss_sum.py`
- Walkthrough: `examples/gauss-sum/README.md`
