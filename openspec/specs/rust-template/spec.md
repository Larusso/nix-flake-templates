## Requirements

### Requirement: Rust template directory structure

The template SHALL live under `templates/rust/` and MUST contain a Nix flake, an optional `.envrc`, and a `.gitignore` that ignores `.direnv`, so that `nix flake new -t <ref>#rust <dir>` copies a single directory that is a valid Nix + Rust project root.

#### Scenario: Template directory exists and is copyable

- **WHEN** the hub flake exposes `templates.rust.path` pointing at `templates/rust`
- **THEN** `nix flake new -t <ref>#rust <target-dir>` copies that directory as the root of the new project

#### Scenario: Copied project has a valid flake

- **WHEN** a user runs `nix flake new -t <ref>#rust ./out` and then `cd out && nix develop`
- **THEN** a devShell is available and provides the Rust toolchain (e.g. `rustc --version` and `cargo --version` succeed)

### Requirement: Rust template flake shape

The template flake SHALL use flake-parts and SHALL apply the rust-overlay (e.g. oxalica/rust-overlay) via `_module.args.pkgs` so that `pkgs.rust-bin` is available. The flake SHALL define runtimeDeps, buildDeps, devDeps, and libPath following the template flake base pattern (AGENTS.md) and SHALL provide devShells: stable (default), nightly, and msrv when `Cargo.toml` exists with `package.rust-version`. The devShell MUST set `RUST_SRC_PATH` in the shellHook. The flake SHALL NOT include OpenSpec.

#### Scenario: Template flake uses flake-parts and rust-overlay

- **WHEN** the template at `templates/rust/flake.nix` is evaluated
- **THEN** it uses `flake-parts.lib.mkFlake` and declares `perSystem` with `_module.args.pkgs` importing nixpkgs with the rust-overlay applied

#### Scenario: Rust toolchain available in devShell

- **WHEN** the user enters the default devShell of a project created from the template
- **THEN** `rustc` and `cargo` are on PATH and invocable (e.g. `rustc --version` and `cargo --version` succeed)

#### Scenario: Multiple devShells for toolchain choice

- **WHEN** the template flake is evaluated
- **THEN** `devShells.stable` (or default) and `devShells.nightly` exist; `devShells.msrv` exists when the project has a `Cargo.toml` with `package.rust-version`

### Requirement: In-template comments for dependency lists

The template flake MUST include a comment block that explains how to add packages to runtimeDeps, buildDeps, and devDeps, with example package names (e.g. runtime: openssl; build: pkg-config, rustPlatform.bindgenHook, makeWrapper; dev: rust-analyzer). The same SHALL apply for libPath (e.g. listing runtime libs so binaries and the shell find them).

#### Scenario: Comments present for dependency lists

- **WHEN** the file `templates/rust/flake.nix` is inspected
- **THEN** it contains comments at or above the runtimeDeps, buildDeps, and devDeps lists that describe how to add packages to each list with at least one example per list

### Requirement: Template references rust-bin and rust-lib templates

The `templates/rust/` README SHALL reference the `rust-bin` and `rust-lib` templates for users who want a complete project scaffold with buildable package outputs, so that users landing in the devShell-only template know where to find the project-ready templates.

#### Scenario: README mentions rust-bin and rust-lib

- **WHEN** the file `templates/rust/README.md` is inspected
- **THEN** it contains references to both `rust-bin` and `rust-lib` templates with a brief explanation that those templates provide ready-to-build project scaffolds

### Requirement: Template includes basic .gitignore

The template SHALL include a `.gitignore` file that ignores the `.direnv` directory so that direnv/nix users do not commit cached data.

#### Scenario: .gitignore ignores .direnv

- **WHEN** the template at `templates/rust/` is inspected
- **THEN** it contains a `.gitignore` file that includes `.direnv` (or an equivalent pattern)

### Requirement: Template has runnable build check

The template flake SHALL expose a `checks` output so that `nix flake check ./templates/rust` verifies the template builds (e.g. the default devShell can be built).

#### Scenario: Flake check passes

- **WHEN** a user runs `nix flake check ./templates/rust` from the repo root (or runs the rust template test script)
- **THEN** the check succeeds (template flake evaluates and the declared check derivation builds)

### Requirement: Rust template tests verify flake content

The Rust template tests SHALL verify flake content, not only that the flake builds. The test script (e.g. `tests/rust/test.sh`) SHALL run content tests by creating a project with `nix flake new -t <hub>#rust <dir>`, then (1) entering the devShell and asserting `rustc` and `cargo` are on PATH and invocable (e.g. `nix develop -c rustc --version` and `nix develop -c cargo --version` succeed), and (2) asserting the generated project's `flake.nix` does not expose a `templates` output. Content tests MAY be skipped (e.g. via an env flag) for a faster build-only run.

#### Scenario: Content test — rustc and cargo in PATH

- **WHEN** the test script runs `nix flake new -t path:repo#rust <temp-dir>` then `nix develop <dir> -c rustc --version` and `nix develop <dir> -c cargo --version`
- **THEN** both commands succeed

#### Scenario: Content test — no templates output

- **WHEN** the test script runs content tests
- **THEN** it asserts the generated project's `flake.nix` does not contain a `templates` output (e.g. grep or equivalent)
