## Requirements

### Requirement: Rust-OpenSpec template directory structure

The template SHALL live under `templates/rust-openspec/` and MUST contain a Nix flake, a `README.md`, a `.envrc`, and a `.gitignore` that ignores `.direnv`, so that `nix flake new -t <ref>#rust-openspec <dir>` copies a single directory that is a valid Nix + Rust + OpenSpec project root.

#### Scenario: Template directory exists and is copyable

- **WHEN** the hub flake exposes `templates.rust-openspec.path` pointing at `templates/rust-openspec`
- **THEN** `nix flake new -t <ref>#rust-openspec <target-dir>` copies that directory as the root of the new project

#### Scenario: Copied project has a valid flake

- **WHEN** a user runs `nix flake new -t <ref>#rust-openspec ./out` and then `cd out && nix develop`
- **THEN** a devShell is available and provides both the Rust toolchain and the OpenSpec CLI

### Requirement: Rust-OpenSpec template flake shape

The template flake SHALL use flake-parts and SHALL apply the Rust toolchain setup used by `templates/rust/`. The flake SHALL define `runtimeDeps`, `buildDeps`, `devDeps`, and `libPath` following the template flake base pattern in AGENTS.md. The default devShell SHALL include `rustc`, `cargo`, and `openspec`. The flake SHALL provide stable and nightly devShells, MUST set `RUST_SRC_PATH` in the shellHook, and SHALL NOT expose a `templates` output.

#### Scenario: Template flake uses flake-parts and Rust toolchain setup

- **WHEN** the template at `templates/rust-openspec/flake.nix` is evaluated
- **THEN** it uses `flake-parts.lib.mkFlake` and provides the same Rust toolchain structure as `templates/rust/`

#### Scenario: Rust and OpenSpec are available in devShell

- **WHEN** the user enters the default devShell of a project created from the template
- **THEN** `rustc`, `cargo`, and `openspec` are on PATH and invocable

#### Scenario: No templates output in copied flake

- **WHEN** the file at `templates/rust-openspec/flake.nix` is inspected
- **THEN** its `outputs` do not include a `templates` attribute

### Requirement: Rust-OpenSpec README explains post-generation setup

The template README SHALL explain what the template provides and how to start a Rust project after generation, including how to initialize a binary crate, a library crate, or a workspace while keeping OpenSpec available in the same devShell.

#### Scenario: README covers next steps

- **WHEN** the file `templates/rust-openspec/README.md` is inspected
- **THEN** it describes the combined Rust + OpenSpec environment and includes concrete post-generation setup steps for at least one crate initialization path

### Requirement: Rust-OpenSpec template has runnable build check and content tests

The template flake SHALL expose a `checks` output so that `nix flake check ./templates/rust-openspec` verifies the template builds. The repo SHALL provide a test script for the template that creates a project from `#rust-openspec`, verifies `rustc`, `cargo`, and `openspec` are available in the generated devShell, and asserts that the generated project's flake does not expose `templates`.

#### Scenario: Flake check passes

- **WHEN** a user runs `nix flake check ./templates/rust-openspec`
- **THEN** the check succeeds

#### Scenario: Content test verifies combined tooling

- **WHEN** the template test script creates a project from `#rust-openspec` and enters its devShell
- **THEN** `rustc --version`, `cargo --version`, and `openspec --version` all succeed

#### Scenario: Content test verifies generated project is not a template hub

- **WHEN** the template test script inspects the generated project's `flake.nix`
- **THEN** it confirms the file does not expose a `templates` output
