## ADDED Requirements

### Requirement: Automated workflow updates helper-flake locks

The repo SHALL update lock files for helper flakes hosted under `flakes/*/` in the same scheduled workflow that updates template flakes.

#### Scenario: Scheduled run updates helper-flake locks

- **WHEN** the update workflow runs after this change
- **THEN** it runs `nix flake update` in `flakes/oh-my-claudecode/` and `flakes/oh-my-codex/`

### Requirement: Root lock is refreshed during the update workflow

The scheduled update workflow SHALL refresh the root `flake.lock` after updating template and helper-flake locks so the root flake remains current before creating the update PR.

#### Scenario: Root lock updated after helper-flake changes

- **WHEN** the update workflow has updated helper-flake locks
- **THEN** it runs a root-level lock refresh before creating the update PR
