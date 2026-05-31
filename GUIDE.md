# GUIDE.md — the rationale surface

This is the single living home for **why** this template is shaped the way it
is. The build-time design notes (the synthesis bake-off and the PRD pipeline) are
stripped from the released tree on purpose, so the reasoning they carried lives
here and in git. The invariant *laws* those notes settled are not lost — they ship
in [CONTRIBUTING.md](./CONTRIBUTING.md), the contract for changing the template.
Read this once end to end; after that, treat it as reference.

If you only want to *use* the template, [README.md](./README.md) and the
[worked example](./examples/gauss-sum/) are enough. Come here when you want to
know why a convention exists before you change it.

## Table of contents

1. [The core bet](#1--the-core-bet)
2. [Three primitives, three schemas](#2--three-primitives-three-schemas)
3. [Three stances: think, build, write](#3--three-stances-think-build-write)
4. [Checks: contract vs. probe](#4--checks-contract-vs-probe)
5. [The conflict mechanism, end to end](#5--the-conflict-mechanism-end-to-end)
6. [The deterministic shell and scoped guarding](#6--the-deterministic-shell-and-scoped-guarding)
7. [Memory and the cold open](#7--memory-and-the-cold-open)
8. [Vocabulary that self-corrects](#8--vocabulary-that-self-corrects)
9. [Agent compatibility: one source of truth](#9--agent-compatibility-one-source-of-truth)
10. [Versioning, evolution, and the governing rule](#10--versioning-evolution-and-the-governing-rule)
11. [The worked example](#11--the-worked-example)
12. [What this template does not do](#12--what-this-template-does-not-do)
13. [Deferred on purpose](#13--deferred-on-purpose)

---

## 1 — The core bet

The hard part of agent-assisted research is **knowing what you currently believe
and why, after the agent that helped you build it is gone.** Everything here
follows from taking that seriously.

So a **claim** — a statement you are willing to be held to — is the epistemic
spine of the repository. Code realises claims, the paper asserts them,
disagreements are disagreements *about* them. A claim carries not just the belief
but the **Why**: the reason a decision was made, so a cold reader recovers the
justification and not only the conclusion.

But a spine is not a skeleton, and a claim must not be made to carry the day's
narrative or the live disputes as well. Couple those three jobs and you couple
three things that fail differently and at different times: a claim with the
session story folded in goes stale the instant you stop maintaining it; a claim
with its disputes folded in becomes unfindable the moment you have forty claims
and need to know which three are in trouble. So the spine is **flanked by two
separately-queryable registers**: a memory pair you can read cold (§7) and a
disagreement register you can list in one command (§5). Cold-open recovery never
depends on any single surface being perfectly maintained.

The rest of the design is three refusals:

- Do not make exploration pay claim-tax before anything depends on it.
- Do not guard steps where being wrong is cheap and recoverable.
- Do not say anything about how the researcher is feeling.

Hold those three in mind and most of the conventions below explain themselves.

## 2 — Three primitives, three schemas

There are exactly three primitives. Each is a Markdown file with frontmatter, and
**the frontmatter schema is the contract** the deterministic shell validates.

### The claim — `claims/C####-slug.md`

```yaml
---
id: C0007
status: conjecture        # conjecture | settled | retired
opened: 2026-05-29 14:02  # minted by the shell, never by the model
touched: 2026-05-29 16:40
---
```

Four standing body sections: **Statement** (one sentence, the thing believed),
**Why** (the derivation or argument — this is where the *reason* lives),
**Checks** (the table; see §4), and **Attachments** (paths to the code, tests,
figures, and paper sections that realise or cite the claim).

Note what the schema does **not** have: there is no `contested` status. Whether a
claim is disputed is not a fact you maintain by hand — it is *derived* by asking
the conflict register which open conflicts point at this claim. A status you have
to remember to flip is a status that lies. **Disputedness is a join, not a
field.**

### The skill — `skills/<name>/SKILL.md`

```yaml
---
name: build
stance: build             # think | build | write
when: a claim has checks but no green code yet
reads:  [the named claim, CONTEXT.md, the spec it generates]
writes: [specs/, tests/, src/, the claim's Attachments + status]
runs:   [make test, make open-conflict]
halts:  a contract check still red after one honest fix cycle
---
```

They are called *skills* and live in `SKILL.md` files deliberately: that is the
native discovery convention agents already understand, so adopting it rather than
inventing a private word is what makes the template interoperable. The `reads:`
line is checked for being present and list-shaped, and warns when a skill reaches
for the whole repo — a visible smell. Only `build` carries a real `halts:`
condition; for every other skill it is `none`.

Approval behaviour — when the agent must stop and ask before writing — is **not**
a per-skill field. It is one guardrail stated once in `AGENTS.md`, because a rule
duplicated across nine files is a rule that drifts across nine files.

### The conflict — `conflicts/<ts>-<claim>-<check>.md`

```yaml
---
status: open                  # open | closed
repair_side: program          # program | argument | undecided
detected_at: 2026-05-29 16:38
resolved_at: null             # null iff open
claim: C0007                  # the spine object in dispute
check: 7.2                    # the check that surfaced it
---
```

**Two axes, two homes.** The **check class** (`contract` | `probe`) lives on the
check row in the claim and answers *does being red halt at all?* The
**`repair_side`** (`program` | `argument` | `undecided`) lives here on the
conflict and answers *where does the next session look first?* Linking back to
`claim` and `check` ties every dispute to the spine, so the conflict register and
the claim register are two views of one truth, not two things to reconcile.

## 3 — Three stances: think, build, write

Three work modes, made legible without ceremony, by three **stances**:

- **think** — loose exploration: reasoning, reading, interpreting a result.
  Writes prose to `notes/` or scratch code to `playground/`. No claims, no
  checks, no obligations. *You can be wrong here for free.*
- **build** — correctness-critical claim-to-code work, where being wrong is
  expensive. **The only stance with a halt condition.**
- **write** — output for humans: paper sections, supervisor briefs, handoffs,
  generated from committed state.

A stance is **not** a directory, a gate, or a state machine you transition
through. It is a word a skill names in its frontmatter and a word the session
opens with ("we're in build today, picking up C0007"). The legibility comes from
naming the stance; the absence of ceremony comes from refusing to make it a
state. The verbs `think / build / write` each name a stance, a mode, and a
central skill — one vocabulary doing three jobs rather than three to keep aligned.

The nine skills map onto the stances like this:

| Stance | Skills |
|---|---|
| think | `start`, `think`, `pin`, `log` |
| build | `build`, `critique` |
| write | `draft`, `brief`, `intake` |

There is **no skill literally named `write`** — `write` is the stance.

## 4 — Checks: contract vs. probe

This is the most important research-integrity feature in the template, so it gets
its own section. Every check on a claim carries a **class**, and the class —
*and only the class* — decides what a red result means.

- **contract** — an algorithmic promise. The math is authority; if the check is
  red, the **code is wrong**. An ordinary bug. Fix the code; the claim is
  undisturbed. A contract red past one honest fix cycle is the one place the
  `build` stance **halts** (§5).
- **probe** — a theoretical expectation. The math is on trial; if the check is
  red, the **belief may be wrong**. The build does **not** halt — you do not stop
  the world because reality disagreed with a conjecture, that is the entire point
  of running probes — but a red probe **always** opens a conflict and surfaces it
  loudly, then and there.

Treating the two identically is the failure this distinction exists to prevent:
a failing contract is a bug; a failing probe is a discovery that your reasoning
may be off. Collapse them and you get false build failures *and* quiet erosion of
trust when a probe goes red and is found a day later.

One subtlety worth stating plainly: **a red probe opening a conflict is a
skill-procedure obligation, not a shell gate.** The `build` skill's procedure
makes running `make open-conflict … repair_side=argument|undecided` a
non-optional step on any red probe. The shell does not auto-detect a red probe
from the test output — auto-firing from a structured test report is a deliberate
fast-follow (§13). So the discipline lives in the procedure, and no check claims a
red probe mechanically cannot be missed.

## 5 — The conflict mechanism, end to end

One disagreement is one file in `conflicts/`. There is exactly **one** lifecycle,
no matter how the dispute opened:

```
make open-conflict  →  /think (run on the conflicts/ file)  →  make close-conflict
```

**Opening.** A `build` session runs `make test`. A red result is triaged by the
class of the check that went red (§4), and only by that:

- A **contract** went red → the code is presumed wrong. The agent attempts one
  fix cycle. Green? Nothing else happens — an ordinary bug, the claim was never
  in question. Still red after one honest cycle? The agent runs
  `make open-conflict claim=C0007 check=7.1 repair_side=program` and **halts.**
  The `repair_side: program` records that the next session looks at the code
  first. This is **the only halt in the entire suite.**
- A **probe** went red → the math is on trial. The build does *not* block, but it
  *always* opens a conflict (`repair_side: argument` if the math looks wrong,
  `undecided` if it could be either) and says so loudly in the chat.

**Finding.** Either way there is now a file in `conflicts/`. `make status` lists
every open conflict with its claim and repair_side, and `/start` reads the same
list on every cold open. **Nothing depends on a human remembering a dispute
exists.**

**Resolving.** Run `/think` *on the conflict file* — given a `conflicts/` file,
`think` switches from exploration to adjudication. You decide, and the decision is
one of: revise the claim's Why, fix the code, reclassify the check, or retire the
claim. Then `make close-conflict file=…` stamps `resolved_at`, sets
`status: closed`, and commits under the `conflict:` scope. The resolution note is
the commit and the closed file; that *is* the audit trail, not a separate log.
(The schema enforces the invariant `status: open` ⇔ `resolved_at: null`.)

**One more route.** When `make rename` propagates a vocabulary change and detects
that the theory and the code drifted apart in the process, it does not invent a
new alarm — it opens a conflict with `repair_side: argument`, which lives and dies
exactly like every other. *Two axes, two homes, one mechanism, one lifecycle.* A
second person inheriting the repo learns the disagreement system once and knows it
everywhere.

## 6 — The deterministic shell and scoped guarding

Every stochastic step is wrapped by a deterministic one. The `Makefile` (plus
`scripts/`) is the wrapper, and it is the **only** thing that mints timestamps,
ids, and commits. A model never invents a timestamp or a claim id — it reads
`make now` for the clock and `make new-claim` for ids. Never call a test runner,
linter, formatter, or compiler directly; always go through `make`.

The shell surface, roughly:

```
make setup                 # install deps, hooks, adapters, .env; idempotent
make now / now-filename     # the clock, for the model to read not invent
make new-claim name=...      # mint a C-id, scaffold from TEMPLATE
make open-conflict ...       # open a dispute (see §5)
make close-conflict file=... # close it
make test [m=...]            # run checks, optionally one module
make lint / format           # static checks / apply formatting
make rename old=... new=...   # propagate a term; drift opens a conflict
make intake name=...         # land outside material in inbox/ with provenance
make archive file=...        # retire a file without deleting its history
make status                  # the dashboard: open conflicts, recent claims
make paper                   # validate citations, then compile Typst → PDF
make sync                    # regenerate the git-ignored agent adapters
make migrate from=<major>    # walk the migration chain
make validate                # full in CI; scoped in the pre-commit hook
```

**The shell adapts to one language at a time.** `LANGUAGE` (python or r ship
built in) selects only the test/lint/format/install runners behind `make` —
everything else in the shell is language-agnostic. The committed `.env.example`
is the repo default and the value CI reads; a git-ignored `.env` overrides it
locally, and both the Makefile and CI resolve `.env` first, then `.env.example`.
Choosing a language with no built-in adapter does **not** brick the shell: the
language-agnostic targets keep working and only the runner targets ask you to add
one. Adding a language (e.g. `julia`) is a single adapter block in the `Makefile`
plus an optional CI job — there is no plugin system to learn because nothing else
is language-specific.

**Guarding is scoped, not blanket.** The pre-commit hook always runs the cheap
structural validators (it discovers them by globbing `scripts/validate-*.sh`, runs
each independently, and surfaces them together so one failure never masks the
next). But it runs `make test` and `make lint` **only when `src/` or `tests/` is
staged** — because gating a prose-only commit on the full test suite is guarding a
cheap, recoverable thing, which is exactly the over-guarding this design refuses.
One validator, the adapter-sync check, only ever **warns** (§9); a stale
git-ignored copy is a local inconvenience, not a repository fault.

**Commit scopes are a closed vocabulary of twelve**, so the git log is itself a
queryable record of what kind of work happened when:

```
claim:  conflict:  src:  test:  spec:  paper:
note:   brief:     intake:  archive:  template:  log:
```

Every committing action maps to exactly one. (`make rename` commits under `src:`,
because a rename's durable artifact *is* the edited source — there is no
`rename:`/`vocab:`/`journal:` scope.)

## 7 — Memory and the cold open

Three committed surfaces do the remembering, and cold-open recovery
(`/start`) **triangulates all three and trusts none alone:**

- **`JOURNAL.md`** — append-only, newest-first. Nothing ever rewrites a past
  entry, so it **cannot go stale**; it is the load-bearing memory. `/log` appends
  one entry per session (Did / Found / Stuck on / Next / Refs). Its heading is
  exactly `# JOURNAL.md — Research Log`.
- **`STATE.md`** — the standing landing page (aim, open question, key files, open
  conflicts, next move). It is written *by* `/log` and is explicitly **derived**:
  a convenience, allowed to be stale. When it disagrees with the journal or the
  live `make status`, the live sources win.
- **`CONTEXT.md`** — the term→module/claim map (§8).

A cold open is `git clone` → `make setup` → `/start`, where `/start` reads all
three plus the live `make status` conflict list, reconciles them, surfaces the
open question, and asks today's focus. The recovery is robust *because* it
triangulates committed surfaces instead of trusting one. Close every session with
`/log` so the next `/start` inherits the thread.

## 8 — Vocabulary that self-corrects

`CONTEXT.md` maps every registered term to the one module or claim that defines
it, so a word means the same thing across sessions. You do not edit it by hand:
the `pin` skill registers a term as it mints or promotes the claim that owns it,
and `make rename` propagates a term change across the codebase. If a rename makes
the theory and the code disagree, that drift routes into the conflict lifecycle
(§5) rather than failing silently. The map is the single source for "what does
this word mean here" — keep it current through the skills, not by editing.

## 9 — Agent compatibility: one source of truth

The canonical behaviour lives in `skills/*/SKILL.md`, committed. `AGENTS.md` is
the committed entry point every agent reads first. The per-tool pointers —
`CLAUDE.md` and `.windsurfrules` — are committed but
**tiny**: they say "read `AGENTS.md` and `skills/`," nothing more.

The full adapters some tools want — `.claude/`, `.opencode/`, `.agents/` — are
produced by `make sync` and are **git-ignored**. This is the decisive move. The
prior evidence showed a committed-duplicate adapter drifting silently out of step
with its source and needing a dedicated validator to police the drift. A file
that is never committed cannot drift *in the history* — so the bug class is
**deleted, not guarded**, and the validator it required is deleted with it.
`make sync` regenerates on demand; the pre-commit check only *warns* if a local
copy is stale.

To add a new agent: drop a tiny pointer file at the path that agent looks for,
referencing `AGENTS.md` and `skills/`. Switching agents mid-project is safe — the
repo is the source of truth. Whatever agent you use must be able to run shell
commands via `make`; an agent without shell access can read but cannot drive the
template.

## 10 — Versioning, evolution, and the governing rule

The template is a thing other people adopt, so it must be safe and routine to
change. `VERSION` carries a three-segment semantic version (this is **1.0.0**).
`CHANGELOG.md` records every change. `migrations/` holds one migration per
breaking change and is empty until the first; `make migrate from=<major>` walks
the chain so an old repo can be brought current deterministically. `examples/`
ships a worked example (§11), and CI runs `make validate` against the template
itself on every push.

The governing rule for changing the template is one sentence:

> **Every change names the failure it prevents.**

A change proposal states the friction observed, the change made, the failure it
prevents, and its migration impact. A change that cannot name a concrete failure
it prevents is ceremony — and this rule exists precisely to keep ceremony out.
It is the same rule that justifies every cut elsewhere in this design: each
absence below is kept absent because re-adding it would name no failure.

The laws this rule operates on — the invariant `§I` contracts the skills and
scripts cite (`§I1`…`§I11`), the closed commit-scope vocabulary, and the canonical
rosters — live in **[CONTRIBUTING.md](./CONTRIBUTING.md)**, the law sheet for
changing the template. This guide is the *why*; `CONTRIBUTING.md` is the *contract*.

## 11 — The worked example

[`examples/gauss-sum/`](./examples/gauss-sum/) exercises the whole machine on the
schoolbook identity `1 + 2 + … + n = n·(n+1)/2`. It is **sandboxed** — it carries
its own claim, spec, module, and tests under its own folder, so the live registers
you will fill (`claims/`, `conflicts/`, `src/`, `tests/`) stay pristine for you.

It shows, in one place:

- a **claim** (`C0001-gauss-sum.md`) with a Checks table carrying **both**
  classes — a **contract** check (the closed form must equal the naive loop,
  exactly) and a **probe** check (`gauss_sum(n)/n²` approaches `0.5` for large
  `n`);
- a **spec** (`spec.md`), the plan turning each check into a test;
- a **module** (`gauss_sum.py`), pure standard library so it runs on a bare
  checkout;
- **tests** (`test_gauss_sum.py`), one per check, both green.

Run it from the repository root:

```bash
python3 -m pytest examples/gauss-sum -q
```

It ships green so `make validate` stays green; the probe-red → conflict →
resolution path is narrated in the example's README and driven live by the
template's own check, never shipped as a permanently-red test.

## 12 — What this template does not do

Stated openly so you know when you have outgrown it — and so the absences are not
mistaken for omissions.

- **It says nothing about how the researcher feels.** No encouragement, no
  streaks, no mood, no wellness. It is opinionated about the work and silent about
  the person, by design. This is a hard non-goal, not an oversight.
- **It is solo by design.** No multiple developers, shared branches, or team
  ceremony. Every multi-developer affordance was cut on that basis; git is the
  only audit trail.
- **It is not a general project scaffold.** It is a research repository whose
  spine is a claim; outside that purpose it makes no promises.

Several structures you might expect are deliberately absent, each because the job
is already done elsewhere: no `THEORY.md` index (the `claims/` directory *is* the
index); no `config/` tree (a solo researcher's settings live in `pyproject.toml`
and `.env`); no `results/`/`output/` bucket (a result is a figure, a table, or a
derived dataset, each reproducible from config and seed); no decision-record tree
(the *why* already lives in the claim's Why, the journal entry, the closed
conflict, and the changelog). Re-adding any of them would name no failure.

## 13 — Deferred on purpose

Three capabilities are **held back as fast-follows**, each to be built only if its
friction actually recurs — because a fast-follow built before its friction is
observed is overhead that named no failure, the one thing §10's rule forbids:

- **a dedicated `recall` skill** — an on-demand "what did we decide about X" query
  over recent history. Held back until `/start`'s cold-open recovery proves too
  coarse in practice. `/start` covers cold opens; it does not pretend to answer
  mid-session recall.
- **a dedicated `figure` skill** — held back until durable, non-claim plots become
  a real maintenance burden. For now a figure is either claim-attached (produced
  by the `build` pipeline that produced its result) or a static schematic
  committed straight to `paper/figures/`.
- **conflicts auto-firing from a structured test report** — held back until
  hand-running `make open-conflict` after a red probe proves to be the step that
  gets skipped. Until then, opening that conflict is a skill-procedure obligation
  (§4), not a shell gate.

None of these is built speculatively. If you hit the friction, that *is* the
signal — name the failure it prevents, and add it.
