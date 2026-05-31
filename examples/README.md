# `examples/` — worked examples

This directory holds self-contained, runnable demonstrations of the template
working. Each example is **sandboxed**: it carries its own claim, spec, module, and
tests under its own folder, so the live registers you will fill with your own
research — `claims/`, `conflicts/`, `src/`, `tests/` — stay pristine. Read an
example to see the moving parts fit together; then start your own work in the live
registers, not here.

## The guided tour

Start with the one example that exercises the whole system:

### [`gauss-sum/`](gauss-sum/README.md) — one claim, both check classes, the conflict lifecycle

The schoolbook identity `1 + 2 + … + n = n·(n+1)/2`, used as a vehicle to show every
moving part. Read [`gauss-sum/README.md`](gauss-sum/README.md) for the full
walkthrough. In one paragraph:

- A **claim** (`gauss-sum/C0001-gauss-sum.md`) states the belief and carries a
  Checks table with two rows — and **both** check classes:
  - a **`contract`** check (1.1): the closed form must equal the naive loop,
    exactly. `contract` red ⇒ the *code* is wrong; the `build` stance **halts**
    (the one halt in the suite) and opens a conflict with `repair_side: program`.
  - a **`probe`** check (1.2): `gauss_sum(n)/n²` should approach `0.5` for large
    `n`. `probe` red ⇒ the *belief* may be wrong; it opens a conflict with
    `repair_side: argument` and routes to `/think`, but it **never halts**.
- A **spec** (`gauss-sum/spec.md`) is the plan turning each check into a test.
- A **module** (`gauss-sum/gauss_sum.py`) realizes the claim — pure standard
  library, so it runs on a bare checkout.
- **Tests** (`gauss-sum/test_gauss_sum.py`), one per check, both green.

Run it from the repository root:

```bash
python3 -m pytest examples/gauss-sum -q
```

## The two ideas worth carrying away

1. **The check class decides the halt, and it lives on the claim's check row.**
   `contract` = an algorithmic promise (red halts the build; fix the code). `probe`
   = a theoretical expectation (red opens a conflict and routes to `/think`; the
   belief is on trial, the build keeps moving). See §I3.

2. **One disagreement has one lifecycle, and disputedness is never stored.**

   ```
   make open-conflict   →   /think (on the conflicts/ file)   →   make close-conflict
   ```

   Whether a claim is disputed is **derived** by asking the conflict register which
   open conflicts point at it — there is no `disputed` status to forget to flip
   (§I7). The `gauss-sum` walkthrough drives this path end to end.

The example **ships green** — both checks pass, so `make validate` stays green. The
probe-red → conflict → resolution path is narrated in the walkthrough and driven
live by the template's capstone check; it is never shipped as a permanently-red
test.
