## Requirements

### Requirement: Rust-lib-OpenSpec template directory structure

The template SHALL live under `templates/rust-lib-openspec/` and MUST contain a Nix flake, a library `Cargo.toml`, `src/lib.rs`, `Cargo.lock`, a `README.md`, a `.envrc`, and a `.gitignore` that ignores `.direnv` and `target/`, so that `nix flake new -t <ref>#rust-lib-openspec <dir>` copies a complete, buildable Rust library project with OpenSpec available in the devShell.

#### Scenario: Template directory exists and is copyable

- **WHEN** the hub flake exposes `templates.rust-lib-openspec.path` pointing at `templates/rust-lib-openspec`
- **THEN** `nix flake new -t <ref>#rust-lib-openspec <target-dir>` copies that directory as the root of the new project

#### Scenario: Copied project contains library scaffold

- **WHEN** a user runs `nix flake new -t <ref>#rust-lib-openspec ./out`
- **THEN** the directory contains `Cargo.toml`, `src/lib.rs`, and `Cargo.lock`

### Requirement: Rust-lib-OpenSpec template flake shape

The template flake SHALL preserve the library-package behavior of `templates/rust-lib/` and SHALL add OpenSpec to the development environment. The flake SHALL use flake-parts, SHALL define `runtimeDeps`, `buildDeps`, `devDeps`, and `libPath` following the template flake base pattern in AGENTS.md, SHALL provide stable and nightly devShells, and SHALL NOT expose a `templates` output.

#### Scenario: Template flake keeps rust-lib behavior

- **WHEN** the template at `templates/rust-lib-openspec/flake.nix` is evaluated
- **THEN** it provides the same `buildRustPackage`-based library package behavior as `templates/rust-lib/`

#### Scenario: Rust and OpenSpec are available in devShell

- **WHEN** the user enters the default devShell of a project created from the template
- **THEN** `rustc`, `cargo`, and `openspec` are on PATH and invocable

#### Scenario: No templates output in copied flake

- **WHEN** the file at `templates/rust-lib-openspec/flake.nix` is inspected
- **THEN** its `outputs` do not include a `templates` attribute

### Requirement: Rust-lib-OpenSpec template builds a library artifact

The template flake SHALL expose `packages.default` so that `nix build` produces a library artifact under `result/lib/`, while keeping OpenSpec as a development tool rather than a required runtime dependency of the built library unless explicitly added by the template author.

#### Scenario: nix build produces a library

- **WHEN** a user runs `nix build` in a project created from the template
- **THEN** the build succeeds and `./result/lib/` contains at least one `.so` or `.dylib` file

### Requirement: Rust-lib-OpenSpec template has runnable build check and content tests

The template flake SHALL expose a `checks` output so that `nix flake check ./templates/rust-lib-openspec` verifies the template builds. The repo SHALL provide a test script for the template that creates a project from `#rust-lib-openspec`, verifies `rustc`, `cargo`, and `openspec` are available in the generated devShell, verifies `nix build` succeeds, and asserts that the generated project's flake does not expose `templates`.

#### Scenario: Flake check passes

- **WHEN** a user runs `nix flake check ./templates/rust-lib-openspec`
- **THEN** the check succeeds

#### Scenario: Content test verifies combined tooling

- **WHEN** the template test script creates a project from `#rust-lib-openspec` and enters its devShell
- **THEN** `rustc --version`, `cargo --version`, and `openspec --version` all succeed

#### Scenario: Content test verifies library build

- **WHEN** the template test script runs `nix build` in the generated project
- **THEN** the build succeeds and produces at least one library artifact under `result/lib/`
