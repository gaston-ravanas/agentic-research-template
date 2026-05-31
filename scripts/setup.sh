#!/bin/bash
# scripts/setup.sh — bootstrap a fresh clone.
#
# Runs four things, in order:
#   1. Install language dependencies (via `make install`).
#   2. Sync skills/ to the git-ignored agent adapters (via `make sync`).
#   3. Install the pre-commit hook (via `make install-hooks`).
#   4. Create .env from .env.example if missing.
#
# Best-effort by design: a clone with no toolchain or network still completes,
# and any step whose target is not defined is tolerated, not an error — so a
# partial or trimmed checkout still sets up cleanly rather than failing (§I2).

echo "Setting up research project..."

# Load LANGUAGE the same way the Makefile and CI do: the committed .env.example
# default first, then the local .env override (later wins).
for f in .env.example .env; do
  [ -f "$f" ] && { set -a; . "./$f"; set +a; }
done
LANGUAGE=${LANGUAGE:-python}
LANGUAGE=$(echo "$LANGUAGE" | tr '[:upper:]' '[:lower:]')
echo "Language: $LANGUAGE"

case "$LANGUAGE" in
  python)
    echo "Installing Python dev dependencies..."
    ;;
  r)
    if [ ! -f renv.lock ]; then
      echo "No renv.lock found — will run renv::init() to bootstrap."
      echo "If you intend Python instead, set LANGUAGE=python in .env."
    fi
    ;;
  *)
    # No built-in adapter — do not abort setup. Hooks, adapters, and .env still
    # get set up; `make install` will point at the Makefile adapter seam.
    echo "Note: LANGUAGE=$LANGUAGE has no built-in adapter. Continuing setup;"
    echo "'make install' will tell you where to add one (see the Makefile)."
    ;;
esac

# Run `make <target>` only when that target is defined; tolerate absence so a
# partial or trimmed checkout still completes setup rather than failing (§I2).
run_if_target() {
  target="$1"
  if make -n "$target" >/dev/null 2>&1; then
    make "$target" || echo "WARNING: 'make $target' failed; continuing."
  else
    echo "Skipping 'make $target' (target not available yet)."
  fi
}

# 1. Install language deps.
run_if_target install

# 2. Sync canonical skills/ to the git-ignored adapter paths.
run_if_target sync

# 3. Install the pre-commit hook (structural validation before commits).
run_if_target install-hooks

# 4. Create .env from example if not present.
if [ ! -f .env ]; then
  cp .env.example .env
  echo ".env created — edit LANGUAGE if needed."
fi

echo ""
echo "Setup complete. Open your agent and run /start."
