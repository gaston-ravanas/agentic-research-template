# Migration scripts

Each major-version transition ships a script in this directory. Migration is
opt-in via `make migrate from=<major>`, which walks the chain from the user's
starting major version to the current one (read from `VERSION`).

Script naming:

```
1-to-2.sh    — future: major 1 → major 2.
2-to-3.sh    — future: major 2 → major 3.
...
```

Each script is **idempotent** (safe to re-run; running it twice is the same as
running it once) and supports a no-write preview via the `dry_run=1` environment
variable. `make migrate` walks `1-to-2.sh`, `2-to-3.sh`, … in order, so a repo
several majors behind is brought current deterministically.

Empty in 1.0.0 — the first migration ships with 2.0.0. The infrastructure exists
now so the first real migration does not have to invent it; `make migrate from=1`
is a clean no-op today.
