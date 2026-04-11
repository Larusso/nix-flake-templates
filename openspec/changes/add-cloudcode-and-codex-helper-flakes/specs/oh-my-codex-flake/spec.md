## ADDED Requirements

### Requirement: oh-my-codex helper flake is hosted under flakes

The repository SHALL provide an independent helper flake at `flakes/oh-my-codex/` for the upstream project `https://github.com/Yeachan-Heo/oh-my-codex`.

#### Scenario: Helper flake directory exists

- **WHEN** the repository is inspected after implementation
- **THEN** a standalone flake exists at `flakes/oh-my-codex/`

### Requirement: oh-my-codex helper flake packages the upstream project

The helper flake at `flakes/oh-my-codex/` SHALL package the upstream `oh-my-codex` project as a standalone helper flake that is usable without going through the root template interface. The helper flake SHALL expose a default package and a files-only package so users can choose between a fuller CLI-oriented package and a lighter asset-oriented package.

#### Scenario: Helper flake exposes package outputs

- **WHEN** the helper flake is evaluated
- **THEN** it exposes package outputs for the upstream `oh-my-codex` project, including a default package and a files-only package

#### Scenario: Files-only package is available

- **WHEN** a user wants only reusable `oh-my-codex` assets without the main packaged experience
- **THEN** the helper flake provides a files-only package output

### Requirement: oh-my-codex helper flake remains independently usable

The helper flake at `flakes/oh-my-codex/` SHALL remain directly usable as its own flake and SHALL NOT require root-flake forwarding outputs to be valid.

#### Scenario: Direct flake usage works

- **WHEN** a user targets `./flakes/oh-my-codex`
- **THEN** the helper flake can be evaluated independently of the root flake

### Requirement: oh-my-codex helper flake is not a template

The helper flake at `flakes/oh-my-codex/` MUST NOT be exposed through `outputs.templates` and MUST NOT require template-specific scaffolding semantics.

#### Scenario: Helper flake stays outside template interface

- **WHEN** the root flake and helper flake are inspected
- **THEN** `oh-my-codex` is not part of `outputs.templates` and is treated as a standalone helper flake

### Requirement: oh-my-codex README matches sibling helper-flake guidance

The helper flake at `flakes/oh-my-codex/` SHALL include a `README.md` that is similar in structure to the existing `oh-my-claudecode` packaging README, adapted for `oh-my-codex`. It SHALL describe available packages, show flake-input usage, explain direct package consumption, and include update/build guidance relevant to the packaged upstream.

#### Scenario: README covers package and usage guidance

- **WHEN** `flakes/oh-my-codex/README.md` is inspected
- **THEN** it documents the helper flake's packages, installation/consumption examples, and maintenance workflow in a structure similar to the cloudecode sibling README
