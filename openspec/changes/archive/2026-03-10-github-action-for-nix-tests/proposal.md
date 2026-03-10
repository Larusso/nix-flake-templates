## Why

The repo has manual test scripts (`tests/check-openspec-template.sh`, `tests/check-all-templates.sh`) but no automated CI. Adding a GitHub Action to run Nix template tests on push/PR ensures template changes are validated before merge and keeps the flake and template checks repeatable in CI.

## What Changes

- **Test layout**: Restructure tests so there is **one folder per template** under `tests/`, each with a single **`test.sh`** script (e.g. `tests/openspec/test.sh`). A single **runner script** (e.g. `tests/run-all.sh`) **iterates over the template name keys** and runs `tests/<name>/test.sh` for each, so the workflow and “run all” logic stay in sync without per-template script names.
- Add a GitHub Actions workflow that runs Nix template tests in **isolation per template** using a **matrix** (one job per template, e.g. `openspec`). Each job runs **`./tests/${{ matrix.template }}/test.sh`** (same path pattern for every template). No Nix store artifact or cache — each job gets a clean Nix install.
- Workflow runs on **Linux only** (`ubuntu-latest`) to avoid macOS cost; Nix is installed in each job (e.g. via DeterminateSystems/nix-installer-action or cachix/install-nix-action).
- Setup is **extensible**: adding a new template = one new matrix entry + new folder `tests/<name>/` with `test.sh` inside; the iterator script uses the same list of names (or discovers subdirs) so no extra wiring.
- **Lock files in templates**: **Commit `flake.lock`** in each template directory so that `nix flake new` gives a reproducible, known-good set of inputs. To avoid templates going “old and rotten”, add an **automated update** flow (below) so the committed locks stay reasonably current.
- **Automated template flake updates**: A separate workflow (e.g. scheduled weekly or monthly) that updates flake inputs in each template (e.g. `nix flake update` in each `templates/<name>/`), runs the Nix template tests, and opens a PR that **auto-merges** when tests pass so template locks stay current with no manual step.
- Optionally document in README or tests/README that CI runs these checks and that template locks are kept up to date via the scheduled workflow.

## Capabilities

### New Capabilities

- `ci-nix-tests`: GitHub Action workflow that runs the repo’s Nix template tests (flake check and content tests) so that pushes and PRs are validated automatically.
- `template-flake-updates`: Automated system (e.g. scheduled workflow) that updates flake inputs and lock files in each template directory, runs the template tests, and opens a PR that auto-merges when tests pass so the hosted template flakes stay stable but not stale.

### Modified Capabilities

- **root-templates**: Test layout convention changes from `tests/check-<name>-template.sh` and `tests/check-all-templates.sh` to `tests/<name>/test.sh` per template and a single script that iterates over template names (e.g. `tests/run-all.sh`). Root spec’s “Template tests are runnable from repo root” will need to reference the new paths.

## Impact

- **New files**: `.github/workflows/` — at least `nix-tests.yml` (push/PR tests) and an update workflow (e.g. `update-template-flakes.yml`) for scheduled lock updates and PR creation.
- **Convention**: Template directories that are Nix flakes keep a committed `flake.lock`; new templates should follow the same.
- **Dependencies**: GitHub Actions (no new runtime deps for local dev).
- **Systems**: GitHub-hosted Linux runners only; Nix installed per job (no store cache or artifact).
