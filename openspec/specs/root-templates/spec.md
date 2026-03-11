## Requirements

### Requirement: Root flake exposes openspec template

The root flake SHALL provide `outputs.templates.openspec` with a `path` pointing to the OpenSpec template directory and a `description` suitable for `nix flake new` usage.

#### Scenario: openspec template is listed

- **WHEN** the root flake is evaluated
- **THEN** `outputs.templates.openspec` exists and has `path` and `description`

#### Scenario: Template path is the openspec directory

- **WHEN** the root flake is evaluated
- **THEN** `outputs.templates.openspec.path` resolves to the directory that contains the OpenSpec project flake (e.g. `./templates/openspec`)

### Requirement: Default template is openspec

The root flake SHALL provide `outputs.templates.default` so that `nix flake new -t <ref>` (without a template name) uses the same OpenSpec template.

#### Scenario: Default template equals openspec

- **WHEN** the root flake is evaluated
- **THEN** `outputs.templates.default` is defined and refers to the same template as `templates.openspec` (e.g. same path or alias)

### Requirement: Root devShell for developing the hub

The root flake SHALL provide a default devShell that includes the OpenSpec package so that the repo can be developed at the root with OpenSpec (e.g. creating changes, running `openspec` CLI).

#### Scenario: Root devShell includes OpenSpec

- **WHEN** the root flake is evaluated
- **THEN** `outputs.devShells.<system>.default` exists and the devShell includes the OpenSpec tool on PATH

#### Scenario: Template hub and root develop both work

- **WHEN** the root flake provides both `outputs.templates` and `outputs.devShells.default`
- **THEN** `nix flake new -t <ref>#openspec <dir>` succeeds and `nix develop` at repo root enters a shell with `openspec` available

### Requirement: Template tests are runnable from repo root

The repo SHALL provide a `tests/` directory with **one folder per template**, each containing a single **`test.sh`** script (e.g. `tests/openspec/test.sh`) that runs that template's build and content checks from the repo root. A single **runner script** (e.g. `tests/run-all.sh`) SHALL iterate over the template name keys and run `./tests/<name>/test.sh` for each, so that all template checks can be run from the repo root. A `tests/README.md` SHALL document how to run tests (per-template: `./tests/<name>/test.sh`; all: `./tests/run-all.sh`) and how to add tests for new templates.

#### Scenario: Per-template check is runnable

- **WHEN** the user runs `./tests/openspec/test.sh` (or `./tests/<name>/test.sh` for any template name) from the repo root
- **THEN** that template's flake check and content tests run (and succeed if the template is valid)

#### Scenario: Run-all iterates over template names

- **WHEN** the user runs `./tests/run-all.sh` from the repo root
- **THEN** the script iterates over the template name keys and runs `./tests/<name>/test.sh` for each, so that all template checks run

#### Scenario: Tests are documented

- **WHEN** the user reads `tests/README.md`
- **THEN** it describes the folder-per-template layout (`tests/<name>/test.sh`), the runner script (`run-all.sh`) that iterates over template names, and how to add tests for a new template
