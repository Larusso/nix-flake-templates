## ADDED Requirements

### Requirement: oh-my-cloudecode helper flake is hosted under flakes

The repository SHALL provide an independent helper flake at `flakes/oh-my-cloudecode/` that packages the upstream project `https://github.com/Yeachan-Heo/oh-my-claudecode`.

#### Scenario: Helper flake directory exists

- **WHEN** the repository is inspected after implementation
- **THEN** a standalone flake exists at `flakes/oh-my-cloudecode/`

### Requirement: Hosted helper flake uses cloudecode naming

The hosted helper flake SHALL expose its hosted identity using `cloudecode` naming in public-facing descriptions, documentation, and output identifiers where this repo defines the helper flake surface. Legacy `claudecode` naming MAY remain only where it is required to reference the upstream project or upstream source repository accurately.

#### Scenario: Public descriptions use cloudecode name

- **WHEN** the hosted helper flake's `flake.nix` and README are inspected
- **THEN** their public-facing descriptions identify the helper flake as `oh-my-cloudecode`

#### Scenario: Upstream references may retain original name

- **WHEN** the helper flake references the upstream project or source repository
- **THEN** those references may use `oh-my-claudecode` where needed for accuracy

### Requirement: oh-my-cloudecode helper flake remains independently usable

The helper flake at `flakes/oh-my-cloudecode/` SHALL remain directly usable as its own flake and SHALL NOT require root-flake forwarding outputs to be valid.

#### Scenario: Direct flake usage works

- **WHEN** a user targets `./flakes/oh-my-cloudecode`
- **THEN** the helper flake can be evaluated independently of the root flake

### Requirement: oh-my-cloudecode exposes default and files-only packages

The helper flake at `flakes/oh-my-cloudecode/` SHALL expose both a default installable package and a files-only package so users can choose between the main packaged experience and a lighter asset-oriented installation.

#### Scenario: Helper flake exposes both package modes

- **WHEN** the helper flake is evaluated
- **THEN** it exposes a default package and a files-only package

### Requirement: oh-my-cloudecode helper flake is not a template

The helper flake at `flakes/oh-my-cloudecode/` MUST NOT be exposed through `outputs.templates` and MUST NOT require template-specific scaffolding semantics.

#### Scenario: Helper flake stays outside template interface

- **WHEN** the root flake and helper flake are inspected
- **THEN** `oh-my-cloudecode` is not part of `outputs.templates` and is treated as a standalone helper flake
