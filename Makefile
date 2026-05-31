# Makefile — the deterministic shell.
#
# This file is the canonical shell (INVARIANTS §I1, §I2): the only thing in the
# repo that mints timestamps, ids, and commits. A model never invents a
# timestamp or a claim id — it reads `make now` and `make new-claim`.
#
# It is the one shared surface every
# later layer extends: layers APPEND their own targets here (§I2) and never edit
# a target owned by an earlier layer, preserving a forward-only DAG inside one
# file. `make validate` discovers its validators by globbing scripts/validate-*.sh
# and runs each independently, so a layer adds a check by dropping a script in
# scripts/ — with no back-edge into this file.

# Load LANGUAGE (and any other variables). The committed .env.example is the
# repo default; the git-ignored .env is the developer's local override. Later
# includes win, so .env beats .env.example when present. Reading .env.example
# too means a fresh clone and CI (which never have a local .env) still resolve
# the repo's committed language — without anyone committing a .env.
-include .env.example
-include .env
export

LANGUAGE ?= python

# Normalize LANGUAGE to lowercase so r, R, Python, PYTHON all work.
LANGUAGE := $(shell echo $(LANGUAGE) | tr '[:upper:]' '[:lower:]')

# ---------------------------------------------------------------------------
# Language adapters — the runner commands behind LANGUAGE.
# Python and R ship built in. To add another (e.g. julia), copy a block below:
# add an `else ifeq ($(LANGUAGE),julia)` arm setting the five *_CMD variables,
# and (optionally) a matching CI job in .github/workflows/test.yml. Nothing else
# in the shell is language-specific — only these five commands are.
# ---------------------------------------------------------------------------

ifeq ($(LANGUAGE),python)
  TEST_CMD     = pytest tests/ -v
  TEST_MOD_CMD = pytest tests/test_$(m).py -v
  LINT_CMD     = ruff check src/ tests/
  FORMAT_CMD   = ruff format src/ tests/
  INSTALL_CMD  = pip install -e ".[dev]" 2>/dev/null || pip install -e ".[dev]" --break-system-packages
else ifeq ($(LANGUAGE),r)
  TEST_CMD     = Rscript -e "testthat::test_dir('tests/', reporter = 'progress')"
  TEST_MOD_CMD = Rscript -e "testthat::test_file('tests/test_$(m).R')"
  LINT_CMD     = Rscript -e "lintr::lint_dir('src/')"
  FORMAT_CMD   = Rscript -e "styler::style_dir('src/')"
  INSTALL_CMD  = if [ -f renv.lock ]; then Rscript -e "renv::restore()"; else Rscript -e "renv::init()"; fi
else
  # No built-in adapter for this LANGUAGE. Do NOT $(error) here: that aborts the
  # whole Makefile and locks the user out of the language-agnostic targets (now,
  # new-claim, status, the conflict lifecycle, the validators, paper) that need
  # no runner. Instead, defer the failure to only the runner targets, pointing
  # at the seam above. Each *_CMD is a subshell that exits 1 with guidance, so
  # `make test` (and the validate wrapper) fail cleanly while the rest works.
  NO_ADAPTER   = ( echo "No built-in runner for LANGUAGE='$(LANGUAGE)'. Add an adapter block in the Makefile (mirror the python/r blocks), or set LANGUAGE=python|r in .env / .env.example." >&2; exit 1 )
  TEST_CMD     = $(NO_ADAPTER)
  TEST_MOD_CMD = $(NO_ADAPTER)
  LINT_CMD     = $(NO_ADAPTER)
  FORMAT_CMD   = $(NO_ADAPTER)
  INSTALL_CMD  = $(NO_ADAPTER)
endif

.PHONY: setup install now now-filename new-claim status archive \
        test test-module lint format check-language install-hooks validate

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------

# Prepare a fresh clone: install deps, sync adapters, install the hook, seed
# .env. Idempotent. setup.sh tolerates absent later-layer targets (make sync).
setup:
	@bash scripts/setup.sh

# Install language dependencies (Python: editable + dev extras; R: renv).
install:
	$(INSTALL_CMD)

check-language:
	@echo "LANGUAGE=$(LANGUAGE)"

# ---------------------------------------------------------------------------
# Timestamps — the shell mints, the model reads (§I1). Skills call these.
# ---------------------------------------------------------------------------

now:
	@bash scripts/now.sh

now-filename:
	@bash scripts/now.sh file

# ---------------------------------------------------------------------------
# Claims — mint the next sequential C#### id and scaffold a claim (§I1, §I10).
# ---------------------------------------------------------------------------

new-claim:
	@bash scripts/new-claim.sh $(name)

# ---------------------------------------------------------------------------
# Dashboard + archiving
# ---------------------------------------------------------------------------

# The dashboard: open conflicts, recent claims, in-flight specs. Always exits 0.
status:
	@bash scripts/status.sh

# Retire a file without deleting its history: move it under <parent>/archived/
# and commit (archive:). `make status` excludes anything under /archived/.
archive:
	@bash scripts/archive.sh $(file)

# ---------------------------------------------------------------------------
# Test / lint / format — always through make, never the runner directly.
# ---------------------------------------------------------------------------

# pytest exits 5 ("no tests collected"); map that to success so an empty or
# prose-only tree does not fail the gate.
test:
	@$(TEST_CMD); code=$$?; if [ $$code -eq 5 ]; then exit 0; else exit $$code; fi

test-module:
	$(TEST_MOD_CMD)

lint:
	$(LINT_CMD)

format:
	$(FORMAT_CMD)

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

# Aggregate: run test + lint plus every validator, each INDEPENDENTLY (§I2).
# Validators are discovered by globbing scripts/validate-*.sh — drop a script in
# scripts/ and it is picked up, no edit here. Exit codes are collected, never
# short-circuited, so one failure never masks the next. Warn-only validators
# self-exit 0, so the glob never blocks on them.
validate:
	@rc=0; \
	echo "── make test"; $(MAKE) --no-print-directory test || rc=1; \
	echo "── make lint"; $(MAKE) --no-print-directory lint || rc=1; \
	for v in scripts/validate-*.sh; do \
	  [ -e "$$v" ] || continue; \
	  echo "── $$v"; \
	  bash "$$v" || rc=1; \
	done; \
	if [ $$rc -ne 0 ]; then echo "validate: FAILED — see above."; exit 1; fi; \
	echo "validate: all checks passed."

# Install the pre-commit hook. setup.sh calls this; re-run any time. Idempotent.
install-hooks:
	@if [ ! -d .git ]; then \
	  echo "ERROR: not a git repository. Run 'git init' before installing hooks."; \
	  exit 1; \
	fi
	@mkdir -p .git/hooks
	@cp scripts/pre-commit.sh .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "Installed pre-commit hook (.git/hooks/pre-commit)."

# ---------------------------------------------------------------------------
# Frontmatter + skill validators — appended per §I2: own targets only,
# never editing an earlier layer's. `make validate` discovers both via the
# scripts/validate-*.sh glob; these are the by-name entry points.
# ---------------------------------------------------------------------------
.PHONY: validate-frontmatter validate-skills

# Blocking (§I10): the claim and conflict schemas are real contracts.
validate-frontmatter:
	@bash scripts/validate-frontmatter.sh

# Warn-only (§I4): self-exits 0 so the validate glob never blocks on it.
validate-skills:
	@bash scripts/validate-skills.sh

# ---------------------------------------------------------------------------
# Conflict lifecycle + rename drift — the single §5 disagreement
# mechanism (INVARIANTS §I3). Appended per §I2: own targets only, never editing
# an earlier layer's. open/close-conflict map to the `conflict:` scope;
# `make rename` stages source edits for a `src:` commit and routes belief-side
# drift into the SAME lifecycle (a `conflict:` drift conflict), never a 2nd alarm.
# ---------------------------------------------------------------------------
.PHONY: open-conflict close-conflict rename

# Open one disagreement (status: open, resolved_at: null — the iff, §I3). Does
# NOT commit: the opening side is non-committal. Args validated by the script.
open-conflict:
	@bash scripts/open-conflict.sh "$(claim)" "$(check)" "$(repair_side)"

# Close a conflict: flip to closed, stamp resolved_at, commit under `conflict:`.
close-conflict:
	@bash scripts/close-conflict.sh "$(file)"

# Word-boundary, cross-file identifier rename across src/ + tests/, reconciling
# claims/ (the belief) through a drift conflict rather than a silent rewrite.
# Stages atomically for a `src:` commit unless NO_STAGE=1.
rename:
	@if [ -z "$(old)" ] || [ -z "$(new)" ]; then \
	  echo "Usage: make rename old=X new=Y [NO_STAGE=1]"; \
	  exit 1; \
	fi
	@bash scripts/rename.sh "$(old)" "$(new)" "$(NO_STAGE)"

# ---------------------------------------------------------------------------
# Journal validator — the think layer's only shell target. Appended per
# §I2: own target only, never editing an earlier layer's. `make validate`
# discovers scripts/validate-journal.sh via the scripts/validate-*.sh glob; this
# is the by-name entry point. Blocking (§I8): JOURNAL.md is the append-only,
# newest-first, load-bearing memory surface, so its structure is a real contract.
# ---------------------------------------------------------------------------
.PHONY: validate-journal

validate-journal:
	@bash scripts/validate-journal.sh

# ---------------------------------------------------------------------------
# Intake — the write layer's only shell target. Appended per §I2: own
# target only, never editing an earlier layer's. The one safe doorway for outside
# material: it stamps shell-minted provenance (source + `make now`, §I1),
# lands a quarantine record in inbox/ (or data/raw/<name>/ for a dataset), and
# commits under the `intake:` scope. A missing name is refused by the script.
# ---------------------------------------------------------------------------
.PHONY: intake

intake:
	@bash scripts/intake.sh "$(name)" "$(source)" "$(dataset)"

# ---------------------------------------------------------------------------
# Paper — the paper layer's only shell targets. Appended per §I2: own
# targets only, never editing an earlier layer's. `make paper` validates that
# every citation resolves, then compiles the Typst source deterministically to a
# PDF — no hand-assembly. Both map to the `paper:` scope. The
# compiled PDF is paper/output.pdf, git-ignored (§I11 — no output/
# dir). There is deliberately no paper-stats target.
# ---------------------------------------------------------------------------
.PHONY: paper validate-citations

# Blocking pre-flight: every @key in paper/sections/*.typ must resolve in
# bibliography.bib and no [!! missing @key] markers may remain. The hyphenated
# script name is discovered by the `make validate` glob (scripts/validate-*.sh,
# §I2); this is the by-name wrapper. Passes cleanly when there is no section
# content yet.
validate-citations:
	@bash scripts/validate-citations.sh

# Validate citations first, then compile. Checks for typst before compiling
# (the repo does not vendor it); a missing typst is a clear, recoverable error.
paper: validate-citations
	@command -v typst >/dev/null 2>&1 || { \
	  echo "ERROR: typst not found — install it (https://github.com/typst/typst) and retry."; \
	  exit 1; \
	}
	@typst compile paper/main.typ paper/output.pdf
	@echo "Compiled paper/output.pdf"

# ---------------------------------------------------------------------------
# Agent compatibility — the interop layer's only shell targets.
# Appended per §I2: own targets only, never editing an earlier layer's.
# skills/*/SKILL.md is the one source of truth (§I6); these targets keep the
# git-ignored adapters (.claude/ .opencode/ .agents/) derived from it. Neither
# commits — regenerating a git-ignored file is not a committing action.
# ---------------------------------------------------------------------------
.PHONY: sync validate-sync

# Regenerate the three git-ignored adapters from skills/. Wipes and repopulates
# each, prepending a do-not-edit header to every synced SKILL.md. setup.sh calls
# this; re-run after editing any skill. The adapters are never committed (§I6).
sync:
	@bash scripts/sync.sh

# Warn-only (§I6, §I2): self-exits 0 so neither the pre-commit hook nor the
# `make validate` glob (scripts/validate-*.sh) ever blocks on a stale adapter.
# A stale git-ignored copy is a local inconvenience, not a repository fault.
validate-sync:
	@bash scripts/validate-sync.sh

# ---------------------------------------------------------------------------
# Migration — the evolution layer's only shell target. Appended per
# §I2: own target only, never editing an earlier layer's. `make migrate
# from=<major>` walks migrations/<i>-to-<i+1>.sh from the user's starting major
# to the current one (read from VERSION), so a repo several majors behind is
# brought current deterministically. Empty in 1.0.0: no
# scripts exist yet, so `make migrate from=1` is a clean no-op. Not a committing
# action — running a migration produces no template commit of its own.
# ---------------------------------------------------------------------------
.PHONY: migrate

migrate:
	@if [ -z "$(from)" ]; then \
	  echo "ERROR: specify from=<major> (e.g. from=1)"; \
	  echo "Check the VERSION file or 'git log --diff-filter=A -- VERSION' for history."; \
	  exit 1; \
	fi
	@bash scripts/migrate.sh $(from)
