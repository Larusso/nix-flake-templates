## ADDED Requirements

### Requirement: Repository provides a dedicated helper-flakes area

The repository SHALL provide a top-level `flakes/` directory for standalone helper flakes that are hosted in this repository but are not project templates.

#### Scenario: Helper-flakes directory exists

- **WHEN** the repository is inspected
- **THEN** a top-level `flakes/` directory exists for non-template hosted flakes

### Requirement: Helper flakes are distinct from templates

Flakes hosted under `flakes/` SHALL be treated as separate from the template system. They MUST NOT be required to live under `templates/`, and the repository SHALL continue to use `templates/` as the location for `nix flake new` project templates.

#### Scenario: Templates remain under templates

- **WHEN** the repository layout is inspected after this change
- **THEN** existing project templates still live under `templates/`

#### Scenario: Helper flakes use flakes directory

- **WHEN** a standalone non-template flake is added to this repository
- **THEN** it is placed under `flakes/` rather than under `templates/`

### Requirement: Helper flakes are not exposed as template outputs

The repository SHALL treat helper flakes as hosted flakes only. Helper flakes MUST NOT be exposed through the root flake's `outputs.templates` unless a later change explicitly adds that behavior.

#### Scenario: Root template outputs remain template-only

- **WHEN** the root flake is inspected
- **THEN** helper flakes under `flakes/` are not required to appear in `outputs.templates`

### Requirement: Helper flakes may be re-exported from the root flake as a convenience

Helper flakes under `flakes/` SHALL remain independently usable as standalone flakes. The root flake MAY re-export selected outputs from those helper flakes, such as `packages`, `apps`, or `devShells`, as a convenience layer. Such re-exports MUST NOT be required for a helper flake to be valid, and they MUST NOT change the helper flake into a template.

#### Scenario: Helper flake works directly without root re-export

- **WHEN** a helper flake exists under `flakes/<name>/`
- **THEN** it can be used directly via its own flake path without requiring a root-flake forwarding output

#### Scenario: Root flake forwards selected helper outputs

- **WHEN** the root flake chooses to expose a helper flake convenience entry
- **THEN** it may forward selected outputs from `flakes/<name>/` while the helper flake still remains outside `outputs.templates`

### Requirement: Root flake re-exports concrete helper-flake install packages

For helper flakes that this repository explicitly promotes for easy installation, the root flake SHALL re-export selected package outputs while keeping those helper flakes independent. This change SHALL cover `oh-my-claudecode` and `oh-my-codex`, including their default package and files-only package outputs.

#### Scenario: Root flake re-exports claudecode and codex packages

- **WHEN** the root flake is evaluated after this change
- **THEN** it exposes package re-exports for the default and files-only outputs of both `oh-my-claudecode` and `oh-my-codex`

### Requirement: Repository documentation explains helper-flake scope

The root repository documentation SHALL explain that this repo hosts both project templates and smaller standalone helper flakes, and it SHALL describe `templates/` and `flakes/` as separate areas with different purposes.

#### Scenario: Root documentation distinguishes areas

- **WHEN** a user reads the root repository documentation
- **THEN** it explains that `templates/` is for `nix flake new` templates and `flakes/` is for standalone helper flakes
