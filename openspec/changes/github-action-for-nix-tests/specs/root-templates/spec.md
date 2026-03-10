## MODIFIED Requirements

### Requirement: Template tests are runnable from repo root

The repo SHALL provide a `tests/` directory with **one folder per template**, each containing a single **`test.sh`** script (e.g. `tests/openspec/test.sh`) that runs that template’s build and content checks from the repo root. A single **runner script** (e.g. `tests/run-all.sh`) SHALL iterate over the template name keys and run `./tests/<name>/test.sh` for each, so that all template checks can be run from the repo root. A `tests/README.md` SHALL document how to run tests (per-template: `./tests/<name>/test.sh`; all: `./tests/run-all.sh`) and how to add tests for new templates.

#### Scenario: Per-template check is runnable

- **WHEN** the user runs `./tests/openspec/test.sh` (or `./tests/<name>/test.sh` for any template name) from the repo root
- **THEN** that template’s flake check and content tests run (and succeed if the template is valid)

#### Scenario: Run-all iterates over template names

- **WHEN** the user runs `./tests/run-all.sh` from the repo root
- **THEN** the script iterates over the template name keys and runs `./tests/<name>/test.sh` for each, so that all template checks run

#### Scenario: Tests are documented

- **WHEN** the user reads `tests/README.md`
- **THEN** it describes the folder-per-template layout (`tests/<name>/test.sh`), the runner script (`run-all.sh`) that iterates over template names, and how to add tests for a new template
