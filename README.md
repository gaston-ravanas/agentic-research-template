# Agentic Research Template

A repository template for a **solo researcher working with AI agents**. The
hard part of this work is *knowing what you currently believe and why, after the
agent that helped you build it is gone.* This template makes that the spine: a
**claim** — a statement you are willing to be held to — is the unit code
realises, the paper asserts, and disagreements are *about*. Nine skills, three
work stances, a journal you can read cold, and a deterministic shell that mints
every timestamp, id, and commit so the model never invents one.

Works with any agent that reads Markdown instruction files —
[Claude Code](https://docs.anthropic.com/en/docs/claude-code),
[OpenCode](https://github.com/sst/opencode),
[Windsurf](https://windsurf.com), or any `AGENTS.md`-aware tool.

> The complete rationale — *why* every piece exists — lives in
> **[GUIDE.md](./GUIDE.md)**. This README gets you running; the guide is the
> single living home for the reasoning.

## Quick start

```bash
# 1. Use this template on GitHub, or clone and re-init history:
git clone https://github.com/gaston-ravanas/agentic-research-template.git my-project
cd my-project
rm -rf .git && git init && git add -A && git commit -m "init"

# 2. Bootstrap the repo (deps, pre-commit hook, agent adapters, .env):
make setup

# 3. Open your agent in the project directory and run:
/start
```

That is the whole cold open: **`git clone` → `make setup` → `/start`.**

> **Shell access required.** Your agent will likely prompt for shell access the
> first time `/start` runs. Approve it — nearly every skill calls `make` for
> timestamps, scaffolding, validation, and commits. An agent that can read files
> but not run `make` cannot drive this template.

## Your first day — three skills

You do not need the whole suite to begin. Day one is three skills:

| Skill | When | What it does |
|---|---|---|
| `/start` | Open every session | Restores context — reads the journal, the derived `STATE.md`, and the live conflict list, then asks what you are working on. |
| `/think` | Explore | Loose, cheap reasoning. Writes prose to `notes/`, scratch code to `playground/`. No claims, no checks, no obligations — being wrong here is free. |
| `/log` | Close every session | Appends what happened to `JOURNAL.md` so the next `/start` inherits the thread. |

Everything else — promoting a note into a load-bearing claim (`/pin`), making
code correct (`/build`), writing the paper (`/draft`) — you reach for when the
work calls for it. The full roster is in [GUIDE.md](./GUIDE.md).

## What you get

- **Nine agent skills** across three stances — `think` (explore), `build` (make
  code correct), `write` (produce outward material). One vocabulary, no ceremony
  on the cheap modes.
- **`claims/`** — the epistemic spine. One file per belief, each carrying its
  **Why**, its checks, and the code that realises it.
- **`conflicts/`** — a findable disagreement register. One file per dispute;
  `make status` lists every open one. Whether a claim is disputed is *derived*,
  never a flag you forget to flip.
- **Contract vs. probe checks** — a check is either an algorithmic *contract*
  (red means the code is wrong; the build halts) or a theoretical *probe* (red
  means the belief may be wrong; a conflict opens, the build keeps moving).
- **Triangulated memory** — `JOURNAL.md` (append-only, load-bearing),
  `STATE.md` (derived, allowed to be stale), and the live `make status` list.
  Cold-open recovery trusts none of them alone.
- **A deterministic shell** — the `Makefile` and `scripts/` mint every
  timestamp, id, and commit. Pre-commit guarding is *scoped*: tests run only
  when `src/`/`tests/` is staged, never on a prose-only commit.
- **Typst paper path** — `paper/` is the paper's source; `make paper` validates
  citations then compiles to PDF. No hand-assembly step.
- **One worked example** — [`examples/gauss-sum/`](./examples/gauss-sum/) drives
  a real claim with both a contract and a probe check through the whole machine.
- **Language-adaptive** — Python by default, R via `LANGUAGE=r` in `.env`. The
  shell picks the runner; skills are language-agnostic.

## The nine skills

| Skill | Stance | Reach for it when |
|---|---|---|
| `/start` | think | Session opener — restore context after a cold open. |
| `/think` | think | Cheap exploration; also the one path that adjudicates a `conflicts/` file. |
| `/pin` | think | Promote a hardened note into a load-bearing claim. |
| `/log` | think | Session closer — append to `JOURNAL.md`. |
| `/build` | build | A claim has checks but no green code — spec, RED tests, then `src/`. |
| `/critique` | build | Adversarial read of one artifact before something leans on it. |
| `/draft` | write | Turn settled claims into paper prose under `paper/sections/`. |
| `/brief` | write | Generate a digest or handoff from committed state. |
| `/intake` | write | Land outside material with provenance, quarantined until promoted. |

There is no skill literally named `write` — `write` is a stance, not a command.

## Agent compatibility

| Agent | Entry point | Skills discovery path |
|---|---|---|
| Any `AGENTS.md`-aware agent | `AGENTS.md` | `.agents/skills/` |
| Claude Code | `CLAUDE.md` → `AGENTS.md` | `.claude/skills/` |
| OpenCode | `AGENTS.md` | `.opencode/skills/` |
| Windsurf | `.windsurfrules` → `AGENTS.md` | (no project-scoped slash commands) |

`skills/*/SKILL.md` is the canonical, committed source. The `.claude/`,
`.opencode/`, and `.agents/` adapters are **generated by `make sync` and
git-ignored** — a file never committed cannot drift. After editing any skill,
run `make sync`.

## Read next

- **[GUIDE.md](./GUIDE.md)** — the rationale surface: the core bet, the three
  primitives, the conflict mechanism, the deterministic shell, versioning, and
  the stated non-goals.
- **[AGENTS.md](./AGENTS.md)** — what the agent itself reads first, every session.
- **[CONTRIBUTING.md](./CONTRIBUTING.md)** — the contract for *changing* the
  template: the governing rule, the invariant `§I` laws the skills cite, and the
  commit-scope vocabulary. Read it before evolving the template or cutting a version.
- **[examples/gauss-sum/](./examples/gauss-sum/)** — the worked example.

## License

MIT — see [LICENSE](./LICENSE). Use it, fork it, adapt it; attribution
appreciated, not required.
