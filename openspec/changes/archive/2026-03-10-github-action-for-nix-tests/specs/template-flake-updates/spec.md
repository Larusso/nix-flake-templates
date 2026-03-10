## ADDED Requirements

### Requirement: Template Nix flakes include a committed lock file

Each template directory that is a Nix flake (contains `flake.nix`) SHALL include a committed `flake.lock` so that projects created with `nix flake new -t ...#<template> <dir>` get a reproducible, known-good set of inputs without requiring immediate manual updates.

#### Scenario: Template has flake.lock

- **WHEN** a template directory under `templates/<name>/` contains `flake.nix`
- **THEN** it also contains a committed `flake.lock` file

### Requirement: Automated workflow updates template flake inputs

The repo SHALL provide an automated process (e.g. a scheduled GitHub Actions workflow) that updates flake inputs and lock files in each template directory so that hosted template flakes stay current and do not become stale.

#### Scenario: Scheduled run updates template locks

- **WHEN** the update workflow runs (e.g. on a schedule such as weekly or monthly)
- **THEN** it runs `nix flake update` (or equivalent) in each template directory that is a Nix flake (using the same template name keys as the test layout, e.g. from a list or `templates/*/`), producing updated lock files (and any flake.nix changes if inputs were added/removed)

#### Scenario: Updates are validated by template tests

- **WHEN** the update workflow has produced changes to template flake files
- **THEN** it runs the same Nix template tests (e.g. the iterator script `tests/run-all.sh` or the same matrix running `tests/<name>/test.sh`) so that updates are only proposed when tests pass

#### Scenario: Updates are applied via auto-merge

- **WHEN** the update workflow has changes and tests pass
- **THEN** it opens a pull request with the updated lock files and auto-merges it (e.g. merges to the default branch when the workflow’s checks pass), so template locks are updated without manual review

### Requirement: Update workflow is extensible for new templates

The update workflow SHALL be structured so that adding a new template only requires including that template in the set of directories to update (e.g. same matrix or list as the test workflow), with no change to shared logic.

#### Scenario: New template included in update loop

- **WHEN** a new template is added under `templates/<name>/` with a flake and lock file
- **THEN** including it in the update workflow (e.g. one extra matrix value or path) causes its flake inputs to be updated on the same schedule as existing templates
