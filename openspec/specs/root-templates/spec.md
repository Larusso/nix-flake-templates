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

The repo SHALL provide a `tests/` directory with scripts to run each template's build and content checks from the repo root (e.g. `tests/check-openspec-template.sh` runs the flake check and content tests such as openspec in PATH and no `templates` output), and a script to run all template checks (e.g. `tests/check-all-templates.sh`). A `tests/README.md` SHALL document how to run tests and how to add tests for new templates.

#### Scenario: OpenSpec template check is runnable

- **WHEN** the user runs `./tests/check-openspec-template.sh` from the repo root
- **THEN** the OpenSpec template's flake check and content tests run (and succeed if the template is valid)

#### Scenario: Tests are documented

- **WHEN** the user reads `tests/README.md`
- **THEN** it describes how to run template tests (including content tests) and how to add tests for a new template
