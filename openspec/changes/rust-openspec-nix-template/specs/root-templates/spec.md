## ADDED Requirements

### Requirement: Root flake exposes Rust-OpenSpec templates

The root flake SHALL provide `outputs.templates.rust-openspec`, `outputs.templates.rust-bin-openspec`, and `outputs.templates.rust-lib-openspec`, each with a `path` pointing to its template directory and a `description` suitable for `nix flake new` usage.

#### Scenario: Rust-OpenSpec templates are listed

- **WHEN** the root flake is evaluated
- **THEN** `outputs.templates.rust-openspec`, `outputs.templates.rust-bin-openspec`, and `outputs.templates.rust-lib-openspec` all exist and each has `path` and `description`

#### Scenario: Template paths match combination directories

- **WHEN** the root flake is evaluated
- **THEN** `outputs.templates.rust-openspec.path` resolves to `./templates/rust-openspec`, `outputs.templates.rust-bin-openspec.path` resolves to `./templates/rust-bin-openspec`, and `outputs.templates.rust-lib-openspec.path` resolves to `./templates/rust-lib-openspec`

### Requirement: Rust-OpenSpec template tests are runnable from repo root

The repo SHALL provide test scripts `tests/rust-openspec/test.sh`, `tests/rust-bin-openspec/test.sh`, and `tests/rust-lib-openspec/test.sh` that run build and content checks from the repo root. The runner script `tests/run-all.sh` SHALL include all three template names so those test scripts run as part of the aggregate template checks.

#### Scenario: Combination template checks are runnable

- **WHEN** the user runs `./tests/rust-openspec/test.sh`, `./tests/rust-bin-openspec/test.sh`, or `./tests/rust-lib-openspec/test.sh` from the repo root
- **THEN** the corresponding template's build and content checks run

#### Scenario: Run-all includes combination templates

- **WHEN** the user runs `./tests/run-all.sh` from the repo root
- **THEN** the script runs `./tests/rust-openspec/test.sh`, `./tests/rust-bin-openspec/test.sh`, and `./tests/rust-lib-openspec/test.sh` as part of iterating over template names
