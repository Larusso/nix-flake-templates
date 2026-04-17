## ADDED Requirements

### Requirement: GitHub Action runs helper-flake tests

The repo SHALL provide GitHub Actions coverage for helper flakes hosted under `flakes/`, using the same `tests/<name>/test.sh` pattern as other checked flake surfaces.

#### Scenario: Helper flakes are in CI matrix

- **WHEN** the CI workflow is inspected after this change
- **THEN** it includes `oh-my-claudecode` and `oh-my-codex` in the matrix of checked repo flakes

#### Scenario: Helper-flake test scripts run from repo root

- **WHEN** the workflow runs helper-flake jobs
- **THEN** it executes `./tests/oh-my-claudecode/test.sh` and `./tests/oh-my-codex/test.sh` from the repository root

### Requirement: Test layout covers helper flakes

The repo SHALL organize helper-flake tests under `tests/` using the same folder-per-name pattern as templates, so the shared runner can execute both template and helper-flake checks.

#### Scenario: Helper-flake test folders exist

- **WHEN** the repository is inspected after this change
- **THEN** `tests/oh-my-claudecode/test.sh` and `tests/oh-my-codex/test.sh` exist
