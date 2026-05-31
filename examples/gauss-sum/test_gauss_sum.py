"""Tests for the gauss-sum worked example — colocated, standard-library only.

Run from the repository root:

    python3 -m pytest examples/gauss-sum -q

There is no ``__init__.py`` in this directory on purpose: under pytest's default
"prepend" import mode, this folder is put on ``sys.path`` so the colocated module
imports plainly as ``gauss_sum`` (no ``examples.gauss-sum`` package — the hyphen
is not a legal Python identifier anyway).

One test per row of claim C0001's Checks table:

  - ``test_contract_*`` realizes check 1.1 (class: contract) — an algorithmic
    promise. Red here means the CODE is wrong; under the ``build`` stance the line
    halts (a conflict with ``repair_side: program``).

  - ``test_probe_*`` realizes check 1.2 (class: probe) — a theoretical
    expectation. Red here means the BELIEF may be wrong; it opens a conflict
    (``repair_side: argument``) and routes to ``/think``, but it never halts the
    build.

Both ship GREEN so ``make validate`` stays green. The probe-red path is *narrated*
in README.md and *driven live* by the capstone check (it never ships red — a red
probe is a skill obligation, not a CI gate; INVARIANTS §I3).
"""

import random

from gauss_sum import gauss_sum


def test_contract_closed_form_equals_naive_loop():
    """Check 1.1 (contract): the closed form equals 1+2+...+n, exactly."""
    rng = random.Random(8675309)
    for _ in range(200):
        n = rng.randint(0, 10_000)
        assert gauss_sum(n) == sum(range(1, n + 1)), f"closed form wrong at n={n}"


def test_probe_ratio_approaches_one_half():
    """Check 1.2 (probe): gauss_sum(n) / n**2 -> 0.5 as n grows large.

    The ratio is (n + 1) / (2n) = 0.5 + 1/(2n), which converges to 0.5 from above.
    A tolerance of 1e-3 is already satisfied by n = 1000 (the term 1/(2n) = 5e-4).
    """
    tolerance = 1e-3
    for n in (10**3, 10**4, 10**5, 10**6):
        ratio = gauss_sum(n) / (n * n)
        assert abs(ratio - 0.5) < tolerance, f"ratio drifted at n={n}: {ratio}"
