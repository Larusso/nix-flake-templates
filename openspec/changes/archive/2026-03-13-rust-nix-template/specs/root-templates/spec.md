## ADDED Requirements

### Requirement: Root flake exposes rust template

The root flake SHALL provide `outputs.templates.rust` with a `path` pointing to the Rust template directory (`templates/rust`) and a `description` suitable for `nix flake new` usage.

#### Scenario: rust template is listed

- **WHEN** the root flake is evaluated
- **THEN** `outputs.templates.rust` exists and has `path` and `description`

#### Scenario: Template path is the rust directory

- **WHEN** the root flake is evaluated
- **THEN** `outputs.templates.rust.path` resolves to the directory that contains the Rust project flake (e.g. `./templates/rust`)

### Requirement: Rust template tests are runnable from repo root

The repo SHALL provide a test script for the rust template (e.g. `tests/rust/test.sh`) that runs that template's build and content checks from the repo root. The runner script (e.g. `tests/run-all.sh`) SHALL include the rust template so that when it iterates over template names, `./tests/rust/test.sh` is run for the rust template. The `tests/README.md` SHALL document the rust template test (e.g. `./tests/rust/test.sh`) alongside other templates.

#### Scenario: Rust template check is runnable

- **WHEN** the user runs `./tests/rust/test.sh` from the repo root
- **THEN** the rust template's flake check and content tests run (and succeed if the template is valid)

#### Scenario: Run-all includes rust template

- **WHEN** the user runs `./tests/run-all.sh` from the repo root
- **THEN** the script runs `./tests/rust/test.sh` as part of iterating over template names
