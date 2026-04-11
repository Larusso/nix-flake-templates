## ADDED Requirements

### Requirement: Automated workflow updates helper-flake locks

The repo SHALL update lock files for helper flakes hosted under `flakes/*/` in the same scheduled workflow that updates template flakes.

#### Scenario: Scheduled run updates helper-flake locks

- **WHEN** the update workflow runs after this change
- **THEN** it runs `nix flake update` in `flakes/oh-my-cloudecode/` and `flakes/oh-my-codex/`

### Requirement: Root lock is refreshed after helper-flake updates

When helper flakes are wired into the root flake as path inputs, the scheduled update workflow SHALL refresh the root `flake.lock` after updating helper-flake locks so the root lock stays consistent with the current helper-flake input graph.

#### Scenario: Root lock updated after helper-flake changes

- **WHEN** the update workflow has updated helper-flake locks
- **THEN** it runs a root-level lock refresh before creating the update PR
