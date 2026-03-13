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

### Requirement: Root flake exposes rust template

The root flake SHALL provide `outputs.templates.rust` with a `path` pointing to the Rust template directory (`templates/rust`) and a `description` suitable for `nix flake new` usage.

#### Scenario: rust template is listed

- **WHEN** the root flake is evaluated
- **THEN** `outputs.templates.rust` exists and has `path` and `description`

#### Scenario: Template path is the rust directory

- **WHEN** the root flake is evaluated
- **THEN** `outputs.templates.rust.path` resolves to the directory that contains the Rust project flake (e.g. `./templates/rust`)

### Requirement: Root flake exposes rust-bin template

The root flake SHALL provide `outputs.templates.rust-bin` with a `path` pointing to the Rust binary template directory (`templates/rust-bin`) and a `description` suitable for `nix flake new` usage.

#### Scenario: rust-bin template is listed

- **WHEN** the root flake is evaluated
- **THEN** `outputs.templates.rust-bin` exists and has `path` and `description`

#### Scenario: Template path is the rust-bin directory

- **WHEN** the root flake is evaluated
- **THEN** `outputs.templates.rust-bin.path` resolves to `./templates/rust-bin`

### Requirement: Root flake exposes rust-lib template

The root flake SHALL provide `outputs.templates.rust-lib` with a `path` pointing to the Rust library template directory (`templates/rust-lib`) and a `description` suitable for `nix flake new` usage.

#### Scenario: rust-lib template is listed

- **WHEN** the root flake is evaluated
- **THEN** `outputs.templates.rust-lib` exists and has `path` and `description`

#### Scenario: Template path is the rust-lib directory

- **WHEN** the root flake is evaluated
- **THEN** `outputs.templates.rust-lib.path` resolves to `./templates/rust-lib`

### Requirement: Rust template tests are runnable from repo root

The repo SHALL provide a test script for the rust template (`tests/rust/test.sh`) that runs that template's build and content checks from the repo root. The runner script (`tests/run-all.sh`) SHALL include the rust template so that `./tests/rust/test.sh` is run. The `tests/README.md` SHALL document the rust template test alongside other templates.

#### Scenario: Rust template check is runnable

- **WHEN** the user runs `./tests/rust/test.sh` from the repo root
- **THEN** the rust template's flake check and content tests run (and succeed if the template is valid)

#### Scenario: Run-all includes rust template

- **WHEN** the user runs `./tests/run-all.sh` from the repo root
- **THEN** the script runs `./tests/rust/test.sh` as part of iterating over template names

### Requirement: Rust-bin and rust-lib template tests are runnable from repo root

The repo SHALL provide test scripts for both new templates (`tests/rust-bin/test.sh` and `tests/rust-lib/test.sh`) that run build and content checks from the repo root. The runner script (`tests/run-all.sh`) SHALL include both so that `./tests/rust-bin/test.sh` and `./tests/rust-lib/test.sh` are run when iterating over template names. The CI matrix SHALL include `rust-bin` and `rust-lib`.

#### Scenario: Rust-bin template check is runnable

- **WHEN** the user runs `./tests/rust-bin/test.sh` from the repo root
- **THEN** the rust-bin template's flake check and content tests run (and succeed if the template is valid)

#### Scenario: Rust-lib template check is runnable

- **WHEN** the user runs `./tests/rust-lib/test.sh` from the repo root
- **THEN** the rust-lib template's flake check and content tests run (and succeed if the template is valid)

#### Scenario: Run-all includes rust-bin and rust-lib templates

- **WHEN** the user runs `./tests/run-all.sh` from the repo root
- **THEN** the script runs both `./tests/rust-bin/test.sh` and `./tests/rust-lib/test.sh` as part of iterating over template names

#### Scenario: CI matrix includes rust-bin and rust-lib

- **WHEN** the CI workflow `.github/workflows/nix-tests.yml` is inspected
- **THEN** the template matrix includes `rust-bin` and `rust-lib`

### Requirement: Root flake exposes Rust-OpenSpec templates

The root flake SHALL provide `outputs.templates.rust-openspec`, `outputs.templates.rust-bin-openspec`, and `outputs.templates.rust-lib-openspec`, each with a `path` pointing to its template directory and a `description` suitable for `nix flake new` usage.

#### Scenario: Rust-OpenSpec templates are listed

- **WHEN** the root flake is evaluated
- **THEN** `outputs.templates.rust-openspec`, `outputs.templates.rust-bin-openspec`, and `outputs.templates.rust-lib-openspec` all exist and each has `path` and `description`

#### Scenario: Template paths match combination directories

- **WHEN** the root flake is evaluated
- **THEN** `outputs.templates.rust-openspec.path` resolves to `./templates/rust-openspec`, `outputs.templates.rust-bin-openspec.path` resolves to `./templates/rust-bin-openspec`, and `outputs.templates.rust-lib-openspec.path` resolves to `./templates/rust-lib-openspec`

### Requirement: Rust-OpenSpec template tests are runnable from repo root

The repo SHALL provide test scripts `tests/rust-openspec/test.sh`, `tests/rust-bin-openspec/test.sh`, and `tests/rust-lib-openspec/test.sh` that run build and content checks from the repo root. The runner script `tests/run-all.sh` SHALL include all three template names so those test scripts run as part of the aggregate template checks. The CI workflow `.github/workflows/nix-tests.yml` SHALL include the three combination template names in its matrix.

#### Scenario: Combination template checks are runnable

- **WHEN** the user runs `./tests/rust-openspec/test.sh`, `./tests/rust-bin-openspec/test.sh`, or `./tests/rust-lib-openspec/test.sh` from the repo root
- **THEN** the corresponding template's build and content checks run

#### Scenario: Run-all includes combination templates

- **WHEN** the user runs `./tests/run-all.sh` from the repo root
- **THEN** the script runs `./tests/rust-openspec/test.sh`, `./tests/rust-bin-openspec/test.sh`, and `./tests/rust-lib-openspec/test.sh` as part of iterating over template names

#### Scenario: CI matrix includes combination templates

- **WHEN** the CI workflow `.github/workflows/nix-tests.yml` is inspected
- **THEN** the template matrix includes `rust-openspec`, `rust-bin-openspec`, and `rust-lib-openspec`
