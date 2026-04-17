# Repo flake tests

Each checked flake surface in the repo has its own folder under `tests/` with a single `test.sh` script. A runner script iterates over all folders and runs their tests.

## Layout

- **`tests/<name>/test.sh`** — one script per checked surface (template or helper flake), for example `tests/openspec/test.sh` or `tests/oh-my-codex/test.sh`. Run from repo root: `./tests/<name>/test.sh`.
- **`tests/run-all.sh`** — iterates over `tests/*/` and runs `./tests/<name>/test.sh` for each. Run from repo root: `./tests/run-all.sh`.

## Running tests

From the **repository root**:

- **One checked flake**: `./tests/openspec/test.sh`, `./tests/rust/test.sh`, `./tests/oh-my-claudecode/test.sh`, `./tests/oh-my-codex/test.sh`, etc.
- **All repo flake checks**: `./tests/run-all.sh`
- **Build-only** (skip content tests): `SKIP_CONTENT_TESTS=1 ./tests/openspec/test.sh`

CI runs the same tests on push and PR (matrix, one job per checked flake surface, Linux only). Template and helper-flake lock files are kept up to date by a scheduled workflow that opens a PR when updates pass tests.

## What is tested

- **openspec** (`tests/openspec/test.sh`)
  - **Build**: The template flake evaluates and its default devShell builds (`nix flake check`).
  - **Content**: `nix flake new -t path:repo#openspec <temp-dir>` is run; then we verify (1) `openspec` is on PATH in the devShell, and (2) the generated project flake does not expose a `templates` output (projects stay consumers).

- **rust** (`tests/rust/test.sh`)
  - **Build**: The template flake evaluates and its default devShell builds (`nix flake check`).
  - **Content**: `nix flake new -t path:repo#rust <temp-dir>` is run; then we verify (1) `rustc` and `cargo` are on PATH in the devShell (stable + nightly), and (2) the generated project flake does not expose a `templates` output.

- **rust-bin** (`tests/rust-bin/test.sh`)
  - **Build**: The template flake evaluates and its default devShell builds (`nix flake check`).
  - **Content**: `nix flake new -t path:repo#rust-bin <temp-dir>` is run; then we verify (1) `rustc` and `cargo` are on PATH (stable + nightly), (2) `nix build` produces a runnable binary, (3) msrv devShell works when `rust-version` is added to `Cargo.toml`, and (4) the generated project flake does not expose a `templates` output.

- **rust-lib** (`tests/rust-lib/test.sh`)
  - **Build**: The template flake evaluates and its default devShell builds (`nix flake check`).
  - **Content**: `nix flake new -t path:repo#rust-lib <temp-dir>` is run; then we verify (1) `rustc` and `cargo` are on PATH (stable + nightly), (2) `nix build` produces library files (`.so`/`.dylib`) in `result/lib/`, and (3) the generated project flake does not expose a `templates` output.

- **rust-openspec** (`tests/rust-openspec/test.sh`)
  - **Build**: The template flake evaluates and its default devShell builds (`nix flake check`).
  - **Content**: `nix flake new -t path:repo#rust-openspec <temp-dir>` is run; then we verify (1) `rustc`, `cargo`, and `openspec` are on PATH (stable + nightly), and (2) the generated project flake does not expose a `templates` output.

- **rust-bin-openspec** (`tests/rust-bin-openspec/test.sh`)
  - **Build**: The template flake evaluates and its default devShell builds (`nix flake check`).
  - **Content**: `nix flake new -t path:repo#rust-bin-openspec <temp-dir>` is run; then we verify (1) `rustc`, `cargo`, and `openspec` are on PATH (stable + nightly), (2) `nix build` produces a runnable binary, and (3) the generated project flake does not expose a `templates` output.

- **rust-lib-openspec** (`tests/rust-lib-openspec/test.sh`)
  - **Build**: The template flake evaluates and its default devShell builds (`nix flake check`).
  - **Content**: `nix flake new -t path:repo#rust-lib-openspec <temp-dir>` is run; then we verify (1) `rustc`, `cargo`, and `openspec` are on PATH (stable + nightly), (2) `nix build` produces library files (`.so`/`.dylib`/`.a`) in `result/lib/`, and (3) the generated project flake does not expose a `templates` output.

- **oh-my-claudecode** (`tests/oh-my-claudecode/test.sh`)
  - **Direct flake**: `nix flake show path:repo/flakes/oh-my-claudecode`, `nix build path:repo/flakes/oh-my-claudecode#default`, and `nix build path:repo/flakes/oh-my-claudecode#oh-my-claudecode-files`.
  - **Root re-export**: `nix build path:repo#oh-my-claudecode` and `nix build path:repo#oh-my-claudecode-files`.

- **oh-my-codex** (`tests/oh-my-codex/test.sh`)
  - **Direct flake**: `nix flake show path:repo/flakes/oh-my-codex`, `nix build path:repo/flakes/oh-my-codex#default`, and `nix build path:repo/flakes/oh-my-codex#oh-my-codex-files`.
  - **Root re-export**: `nix build path:repo#oh-my-codex` and `nix build path:repo#oh-my-codex-files`.

## Adding tests for a new template or helper flake

1. Add a flake directory under `templates/<name>/` or `flakes/<name>/` with a committed `flake.lock`.
2. Add **`tests/<name>/test.sh`** that runs the appropriate evaluation/build/content checks from the repo root. Use `REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"` so the script works when run as `./tests/<name>/test.sh`.
3. **CI**: Add `<name>` to the matrix in `.github/workflows/nix-tests.yml`. Keep the update workflow aligned with whatever flake directories need automated lock updates. No change needed to `run-all.sh` — it discovers `tests/*/test.sh` automatically.

## Lock files in repo flakes

Each template or helper flake that is a Nix flake should have a **committed `flake.lock`** so consumers get a reproducible, stable set of inputs. A scheduled workflow updates these locks periodically and opens a PR when tests pass, so repo flakes stay current without going stale.
