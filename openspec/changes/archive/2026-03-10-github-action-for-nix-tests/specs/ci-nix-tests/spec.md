## ADDED Requirements

### Requirement: GitHub Action runs Nix template tests

The repo SHALL provide a GitHub Actions workflow that runs the Nix template test script(s) from the repo root so that pushes and pull requests are validated automatically.

#### Scenario: Workflow runs on push

- **WHEN** a push is made to the default branch (or configured branches)
- **THEN** the workflow is triggered and runs the Nix template tests

#### Scenario: Workflow runs on pull request

- **WHEN** a pull request is opened or updated targeting the default branch (or configured branches)
- **THEN** the workflow is triggered and runs the Nix template tests

#### Scenario: Tests executed are the repo test scripts

- **WHEN** the workflow runs
- **THEN** each job executes the template’s test script from the repository root (e.g. `./tests/${{ matrix.template }}/test.sh`) so that all template checks run in isolation

### Requirement: Test layout — folder per template, one test.sh

The repo SHALL organize template tests so that each template has a directory under `tests/` with a single **`test.sh`** script (e.g. `tests/openspec/test.sh`). A single **runner script** (e.g. `tests/run-all.sh`) SHALL iterate over the template name keys and run `./tests/<name>/test.sh` for each, so that “run all” and CI use the same path pattern.

#### Scenario: Each template has tests/<name>/test.sh

- **WHEN** the repository is inspected
- **THEN** for each template name used in the test matrix there exists a file `tests/<name>/test.sh` that runs that template’s build and content checks

#### Scenario: Runner script iterates over template names

- **WHEN** the user (or CI) runs the “run all” script from the repo root
- **THEN** the script iterates over the template name keys (from a list or by discovering `tests/*/` subdirs) and runs `./tests/<name>/test.sh` for each

### Requirement: Matrix strategy — one job per template

The workflow SHALL use a matrix strategy so that each template has its own job and runs that template’s test script in isolation (e.g. one job runs `./tests/openspec/test.sh`). No Nix store artifact or cache SHALL be used between or within jobs; each job gets a clean Nix environment.

#### Scenario: One job per template

- **WHEN** the workflow runs
- **THEN** there is one matrix job per template (e.g. `template: [openspec]`) and each job runs only `./tests/${{ matrix.template }}/test.sh`

#### Scenario: No store artifact or cache

- **WHEN** the workflow is inspected
- **THEN** it does not upload or download Nix store paths and does not configure a Nix binary cache or store artifact step

### Requirement: Linux-only runners

The workflow SHALL run on Linux runners only (e.g. `ubuntu-latest`), not macOS or Windows, so that cost and runner availability are predictable and the repo can remain private without macOS minute considerations.

#### Scenario: Jobs run on Linux

- **WHEN** the workflow runs
- **THEN** each job uses a Linux runner (e.g. `runs-on: ubuntu-latest`)

### Requirement: Easy to add more templates

The workflow and test layout SHALL be structured so that adding a new template requires only adding one entry to the matrix and adding a new folder `tests/<name>/` with a `test.sh` script; the runner script SHALL use the same template name keys (e.g. from a single list or by discovering `tests/*/`). No change to shared steps or cache logic.

#### Scenario: New template is one matrix entry and one folder

- **WHEN** a new template is added to the repo
- **THEN** enabling it in CI and “run all” requires adding a single matrix value (e.g. the template name), creating `tests/<name>/test.sh`, and including the name in the runner script’s list (or relying on discovery); no other workflow changes are required

### Requirement: Workflow has Nix available

The workflow SHALL run in an environment where Nix is installed so that the template test scripts can run (e.g. flake check and content tests).

#### Scenario: Nix is available in the job

- **WHEN** the workflow job runs
- **THEN** the `nix` command is available on PATH and the template’s check script can run successfully

### Requirement: Workflow file location

The workflow SHALL live under `.github/workflows/` with a descriptive name (e.g. `nix-tests.yml`) so that it is discoverable and maintained as the single CI for Nix template tests.

#### Scenario: Workflow file exists in standard location

- **WHEN** the repository is inspected
- **THEN** at least one workflow file under `.github/workflows/` exists that runs the Nix template tests
