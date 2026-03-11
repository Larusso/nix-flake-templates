# Template tests

Each template has its own folder under `tests/` with a single `test.sh` script. A runner script iterates over all template folders and runs their tests.

## Layout

- **`tests/<name>/test.sh`** — one script per template (e.g. `tests/openspec/test.sh`). Run from repo root: `./tests/openspec/test.sh`.
- **`tests/run-all.sh`** — iterates over `tests/*/` and runs `./tests/<name>/test.sh` for each. Run from repo root: `./tests/run-all.sh`.

## Running tests

From the **repository root**:

- **One template** (e.g. OpenSpec): `./tests/openspec/test.sh` or (Rust): `./tests/rust/test.sh`
- **All templates**: `./tests/run-all.sh`
- **Build-only** (skip content tests): `SKIP_CONTENT_TESTS=1 ./tests/openspec/test.sh`

CI runs the same tests on push and PR (matrix, one job per template, Linux only). Template flake locks are kept up to date by a scheduled workflow that opens and auto-merges a PR when updates pass tests.

## What is tested

- **openspec** (`tests/openspec/test.sh`)
  - **Build**: The template flake evaluates and its default devShell builds (`nix flake check`).
  - **Content**: `nix flake new -t path:repo#openspec <temp-dir>` is run; then we verify (1) `openspec` is on PATH in the devShell, and (2) the generated project flake does not expose a `templates` output (projects stay consumers).

- **rust** (`tests/rust/test.sh`)
  - **Build**: The template flake evaluates and its default devShell builds (`nix flake check`).
  - **Content**: `nix flake new -t path:repo#rust <temp-dir>` is run; then we verify (1) `rustc` and `cargo` are on PATH in the devShell, and (2) the generated project flake does not expose a `templates` output.

## Adding tests for a new template

1. Add a **template directory** under `templates/<name>/` with a Nix flake (and a committed **`flake.lock`** so new projects get a reproducible, known-good set of inputs).
2. Add **`tests/<name>/test.sh`** that runs `nix flake check ./templates/<name>` and any content tests from the repo root. Use `REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"` so the script works when run as `./tests/<name>/test.sh`.
3. **CI**: Add `<name>` to the matrix in `.github/workflows/nix-tests.yml` (and the update workflow discovers templates via `templates/*/`). No change needed to `run-all.sh` — it discovers `tests/*/test.sh` automatically.

## Lock files in templates

Each template that is a Nix flake should have a **committed `flake.lock`** so that `nix flake new` gives new projects a reproducible, stable set of inputs. A scheduled workflow updates these locks periodically and auto-merges the PR when tests pass, so templates stay current without going stale.
