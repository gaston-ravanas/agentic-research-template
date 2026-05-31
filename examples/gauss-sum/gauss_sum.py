"""Gauss sum identity — the closed-form computation of 1 + 2 + ... + n.

Realizes claim C0001 (see C0001-gauss-sum.md). Pure standard library on purpose:
the worked example must run on a bare checkout, with nothing installed beyond a
Python interpreter and pytest, so an adopter can see the system working without
first resolving the project's scientific dependencies.
"""


def gauss_sum(n: int) -> int:
    """Return the sum of the integers from 1 to ``n`` via the closed form.

    ``sum_{k=1}^{n} k = n * (n + 1) / 2``, computed in O(1) integer arithmetic.
    Exactly one of ``n`` and ``n + 1`` is even, so the floor division is exact.

    Raises ``ValueError`` for negative ``n`` — the identity is stated for n >= 0.
    """
    if n < 0:
        raise ValueError("n must be non-negative")
    return n * (n + 1) // 2
