## ADDED Requirements

### Requirement: Rust-lib template directory structure

The template SHALL live under `templates/rust-lib/` and MUST contain a Nix flake, a `Cargo.toml` (library crate with `[lib] crate-type = ["cdylib"]`), `src/lib.rs`, `Cargo.lock`, a `README.md`, a `.envrc`, and a `.gitignore` that ignores `.direnv` and `target/`, so that `nix flake new -t <ref>#rust-lib <dir>` copies a complete, buildable Rust library project.

#### Scenario: Template directory exists and is copyable

- **WHEN** the hub flake exposes `templates.rust-lib.path` pointing at `templates/rust-lib`
- **THEN** `nix flake new -t <ref>#rust-lib <target-dir>` copies that directory as the root of the new project

#### Scenario: Copied project contains Cargo scaffold

- **WHEN** a user runs `nix flake new -t <ref>#rust-lib ./out`
- **THEN** the directory contains `Cargo.toml` (with `[lib] crate-type`), `src/lib.rs`, and `Cargo.lock`

### Requirement: Rust-lib template flake shape

The template flake SHALL use flake-parts and SHALL apply rust-overlay via explicit `pkgs` import in the `let` block so that `pkgs.rust-bin` is available. The flake SHALL define runtimeDeps, buildDeps, devDeps, and libPath following the template flake base pattern (AGENTS.md). The flake SHALL provide devShells: stable (default) and nightly. The flake SHALL include a commented msrv block. The devShell MUST set `RUST_SRC_PATH` in the shellHook. The flake SHALL NOT include OpenSpec or `makeWrapper` in buildDeps (libraries do not need wrapping). The flake SHALL NOT expose a `templates` output.

#### Scenario: Template flake uses flake-parts and rust-overlay

- **WHEN** the template at `templates/rust-lib/flake.nix` is evaluated
- **THEN** it uses `flake-parts.lib.mkFlake` and declares `perSystem` with `pkgs` imported in the `let` block with the rust-overlay applied

#### Scenario: Rust toolchain available in devShell

- **WHEN** the user enters the default devShell of a project created from the template
- **THEN** `rustc` and `cargo` are on PATH and invocable

#### Scenario: Multiple devShells for toolchain choice

- **WHEN** the template flake is evaluated
- **THEN** `devShells.stable` (default) and `devShells.nightly` exist

#### Scenario: No templates output in copied flake

- **WHEN** the file at `templates/rust-lib/flake.nix` is inspected
- **THEN** its `outputs` do not include a `templates` attribute

### Requirement: Rust-lib template builds a library file

The template flake SHALL include an active `rustLibPackage` using `buildRustPackage` with a custom `installPhase` that copies the built shared library (`.so` on Linux, `.dylib` on macOS) to `$out/lib/`. The flake SHALL expose `packages.default` so that `nix build` produces the library output.

#### Scenario: nix build produces a library

- **WHEN** a user runs `nix build` in a project created from the template
- **THEN** the build succeeds and `./result/lib/` contains at least one `.so` or `.dylib` file

### Requirement: In-template comments for dependency lists

The template flake MUST include comment blocks that explain how to add packages to runtimeDeps, buildDeps, devDeps, and libPath, with example package names.

#### Scenario: Comments present for dependency lists

- **WHEN** the file `templates/rust-lib/flake.nix` is inspected
- **THEN** it contains comments at or above the runtimeDeps, buildDeps, devDeps, and libPath lists that describe how to add packages with at least one example per list

### Requirement: Template has runnable build check

The template flake SHALL expose a `checks` output so that `nix flake check ./templates/rust-lib` verifies the template builds.

#### Scenario: Flake check passes

- **WHEN** a user runs `nix flake check ./templates/rust-lib`
- **THEN** the check succeeds

### Requirement: Template includes basic .gitignore

The template SHALL include a `.gitignore` file that ignores `.direnv` and `target/`.

#### Scenario: .gitignore ignores build artifacts

- **WHEN** the template at `templates/rust-lib/` is inspected
- **THEN** it contains a `.gitignore` file that includes `.direnv` and `target`
