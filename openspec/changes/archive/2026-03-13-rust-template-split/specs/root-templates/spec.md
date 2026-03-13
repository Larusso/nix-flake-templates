## ADDED Requirements

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
