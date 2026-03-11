## 1. Restructure tests: folder per template, test.sh, iterator script

- [x] 1.1 Create `tests/<name>/test.sh` per template (e.g. `tests/openspec/test.sh`) — move or recreate the logic from the current `check-openspec-template.sh` so each template has a single script in its folder
- [x] 1.2 Add `tests/run-all.sh` that iterates over the template name keys (from a list or by listing `tests/*/` subdirs) and runs `./tests/<name>/test.sh` for each; ensure it can be run from repo root
- [x] 1.3 Remove or deprecate the old top-level scripts (`tests/check-openspec-template.sh`, `tests/check-all-templates.sh`) once the new layout is in place

## 2. Add GitHub Actions workflow (nix-tests)

- [x] 2.1 Create `.github/workflows/` directory if it does not exist
- [x] 2.2 Add workflow file (e.g. `nix-tests.yml`) that triggers on `push` and `pull_request` to the default branch, with `runs-on: ubuntu-latest` (Linux only)
- [x] 2.3 Configure a matrix over template names (e.g. `template: [openspec]`) so each template has its own job; do not add Nix store cache or artifact steps
- [x] 2.4 In each job: use a Nix installer action (e.g. DeterminateSystems/nix-installer-action or cachix/install-nix-action) so Nix is available, then run `./tests/${{ matrix.template }}/test.sh` from the repository root

## 3. Lock files and automated template updates

- [x] 3.1 Ensure each template that is a Nix flake has a committed `flake.lock` (templates/openspec/ already has one; document this as policy for new templates)
- [x] 3.2 Add workflow (e.g. `update-template-flakes.yml`) that runs on a schedule (e.g. weekly cron), runs `nix flake update` in each `templates/<name>/` that has a flake (same template name keys as tests), then runs the same template tests (e.g. `./tests/run-all.sh` or the same matrix) to validate
- [x] 3.3 In the update workflow: if there are file changes and tests pass, open a PR with the updated lock (and any flake.nix changes) and auto-merge it (e.g. create-pull-request + merge step or gh pr merge; ensure workflow token can merge or branch protection allows it)
- [x] 3.4 Structure the update workflow so adding a new template only requires adding it to the same matrix or list used for tests

## 4. Documentation (optional)

- [x] 4.1 Update tests/README.md to describe the new layout (folder per template, `test.sh`, `run-all.sh` iterating over template names) and how to add a new template; optionally mention in README that CI runs the Nix template tests on push and PR (matrix, Linux only) and that template flake locks are kept up to date via the scheduled update workflow
