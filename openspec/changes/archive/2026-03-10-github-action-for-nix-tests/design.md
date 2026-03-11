## Context

The repo is a Nix flake template hub with an OpenSpec template under `templates/openspec/`. Tests currently live in `tests/`: `check-openspec-template.sh` (flake check + content tests) and `check-all-templates.sh`. This change restructures tests to a folder-per-template layout with a single `test.sh` per template and an iterator script, then adds CI. GitHub Actions is the natural choice for this GitHub-hosted repo.

## Goals / Non-Goals

**Goals:**

- Run the existing Nix template test scripts in GitHub Actions on push and pull_request so that template and flake changes are validated before merge.
- Use a **matrix strategy**: one job per template so each template’s tests run in isolation (no shared Nix store or state between templates).
- Use a standard, maintainable way to get Nix on the runner (e.g. a well-known Nix installer action).
- Make it easy to add more templates later (add one entry to the matrix and a new folder `tests/<name>/test.sh`; the iterator script uses the same template-name keys).
- **Linux only** — use `ubuntu-latest` (or similar) to avoid macOS runner cost and keep the repo private without worrying about public macOS minutes.

**Non-Goals:**

- **No Nix store artifact or cache** — do not upload/download Nix store or use a binary cache in the workflow; each job gets a clean Nix install so nothing intervenes between runs.
- Running on macOS or multiple OSes (Linux only for now).
- Other CI jobs (lint, release, etc.); only Nix template tests.

## Decisions

### Nix on the runner

- **Choice**: Use **DeterminateSystems/nix-installer-action** (or **cachix/install-nix-action**) to install Nix in the workflow.
- **Rationale**: Both are widely used; DeterminateSystems supports Nix 2.x and has a simple `nix-version` input. `install-nix-action` is also common. Either is acceptable; pick one and stick to it for consistency.
- **Alternative**: `nixos/nix` container or a custom Nix container — more setup for little benefit here.

### Test layout: folder per template, one test.sh

- **Choice**: Use a **folder per template** under `tests/`, each with a single **`test.sh`** (e.g. `tests/openspec/test.sh`). A **runner script** (e.g. `tests/run-all.sh`) **iterates over the template name keys** (from a list or by listing `tests/*/` subdirs) and runs `./tests/<name>/test.sh` for each. CI and “run all” share the same convention: one path pattern `tests/<template>/test.sh`.
- **Rationale**: Single convention for every template; adding a template is “add folder + test.sh + one name to the list”. No per-template script naming (no `check-*-template.sh`). The iterator script is the single place that knows the set of template names (or derives it), so the matrix can use the same list.
- **Alternative**: Keep one script per template at top level (`check-<name>-template.sh`) — works but duplicates the naming pattern and forces the workflow to repeat it.

### Matrix: one job per template

- **Choice**: Use a **matrix** with one entry per template (e.g. `template: [openspec]`). Each matrix job runs **`./tests/${{ matrix.template }}/test.sh`** only, so tests run in isolation with no shared Nix store or artifacts between templates.
- **Rationale**: Isolation avoids cross-template interference; same path pattern for every template. The matrix template list and the iterator script’s list (or discovery) stay in sync so “run all” and CI behave identically.
- **Alternative**: Single job running the iterator script — simpler YAML but all templates share one runner; user explicitly prefers matrix isolation.

### Workflow triggers

- **Choice**: Trigger on `push` (branches that matter, e.g. `main`) and `pull_request` (default branch and same branches as push).
- **Rationale**: Validates every PR and every push to the main branch. No need for `workflow_dispatch` unless we want manual runs later.

### Job name and placement

- **Choice**: One workflow file, e.g. `.github/workflows/nix-tests.yml`, with one job that uses a **matrix** over template names (e.g. `strategy.matrix.template: [openspec]`). Job runs on **Linux only** (`runs-on: ubuntu-latest`).
- **Rationale**: Single workflow file; matrix makes “add a template” = add one line to the matrix and add `tests/<name>/test.sh` in a new folder.

## Risks / Trade-offs

- **Runner has no Nix**: Mitigation — use a dedicated Nix installer action so the job always gets Nix.
- **Long run time / flake evaluation**: Mitigation — accept for now; optional later: `SKIP_CONTENT_TESTS=1` for a faster “flake check only” job. No Nix store cache or artifact in scope for this change.
- **Different Nix version locally vs CI**: Mitigation — document or pin Nix version in the workflow so CI is reproducible; consider `.nix-version` or action input if the project adopts it.

### Lock files in templates: commit them

- **Choice**: **Commit `flake.lock`** in each template directory (e.g. `templates/openspec/flake.lock`). Do not omit the lock for “always latest” behavior.
- **Rationale**: When someone runs `nix flake new -t ...#openspec ./my-project`, they get a copy of the template including the lock. With the lock committed, that project has a known-good, reproducible set of inputs from day one — stable and no surprise breakage. Without a lock, the first evaluation would resolve to “latest” at that moment, which can break and forces the user to deal with updates immediately. The downside of committing the lock is that it can go stale; that is addressed by the automated update workflow so the template stays “recent” and creating a project in a year still gives a reasonably fresh lock.
- **Alternative**: Don’t commit lock in templates — projects would always get latest on first eval; simpler template dir but less predictable and more likely to need manual updates after creation.

### Automated template flake updates

- **Choice**: Add a **scheduled workflow** (e.g. `schedule: cron('0 0 * * 0')` for weekly, or monthly) that: (1) checks out the repo, (2) for each template directory runs `nix flake update` (or equivalent) in that directory, (3) runs the existing Nix template test matrix (or the same test script) to verify nothing breaks, (4) if there are changes and tests pass, opens a PR and **auto-merges** it (e.g. when CI is green, using a merge step or branch protection that allows the workflow to merge its own PR). Template locks stay current without manual review.
- **Rationale**: Balances “stable” (committed lock) with “not rotten” (periodic updates). Full auto-merge removes the manual step; as long as tests pass, the updated locks are safe to merge. Adding a new template later only requires including it in the update loop (e.g. same matrix or a list of template paths).
- **Alternative**: Open PR only, maintainer merges — more control but extra manual step. Manual-only updates — no automation; template locks would eventually age.

## Migration Plan

1. Restructure tests: one folder per template under `tests/` with a single `test.sh` each (e.g. move or recreate current OpenSpec check as `tests/openspec/test.sh`). Add `tests/run-all.sh` that iterates over template name keys and runs `./tests/<name>/test.sh` for each.
2. Add `.github/workflows/nix-tests.yml` with: `runs-on: ubuntu-latest` (Linux only), a matrix over template names (e.g. `template: [openspec]`), Nix installer step, and a step that runs `./tests/${{ matrix.template }}/test.sh`. No Nix store cache or artifact steps.
3. Ensure each template directory that is a Nix flake has a committed `flake.lock` (already the case for `templates/openspec/`).
4. Add `.github/workflows/update-template-flakes.yml` (or similar): scheduled trigger (e.g. weekly), job that runs `nix flake update` in each `templates/<name>/`, runs the same template tests (reuse matrix or script), then opens a PR with the lock/file changes and **auto-merges** when tests pass (e.g. create-pull-request + merge step, or gh CLI; ensure the workflow token has permission to merge or use a merge-friendly branch protection setup).
5. Push to a branch and open a PR; confirm both workflows run and template tests pass.
6. Merge; no rollback needed beyond reverting the workflow and test layout changes if required.

## Open Questions

- None; design is sufficient to implement the workflow.
