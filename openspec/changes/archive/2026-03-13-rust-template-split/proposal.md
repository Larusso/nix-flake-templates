## Why

The `rust-nix-template` change shipped a single `templates/rust/` with commented-out binary and library package blocks. Testing revealed that actually using those blocks requires scaffolding a `Cargo.toml`, `src/` files, `Cargo.lock`, adding `makeWrapper` to `buildDeps`, and performing multi-line uncomments across two sections — far more than "uncomment a few lines." Each project type (devShell-only, binary, library) needs a ready-to-build template with its own scaffold so users get a working project immediately after `nix flake new`.

## What Changes

- **`templates/rust/`** (modify): Strip the commented-out binary and library package blocks. This template becomes a pure "Rust devShell" for exploration or adding Rust to an existing project. Update its README to point users to `rust-bin` and `rust-lib` for project scaffolding.
- **`templates/rust-bin/`** (new): Full Rust binary project scaffold — includes `Cargo.toml`, `src/main.rs`, `Cargo.lock`, and a `flake.nix` with an active `buildRustPackage` + `wrapProgram` output, `makeWrapper` in `buildDeps`, and `packages.default`. Ready to `nix build` out of the box.
- **`templates/rust-lib/`** (new): Full Rust library project scaffold — includes `Cargo.toml` (with `[lib] crate-type = ["cdylib"]`), `src/lib.rs`, `Cargo.lock`, and a `flake.nix` with an active library package output using a custom install phase. Ready to `nix build` out of the box.
- **Root flake**: Register `templates.rust-bin` and `templates.rust-lib`.
- **Tests**: New `tests/rust-bin/test.sh` and `tests/rust-lib/test.sh` that build the package outputs and verify artifacts. Simplify `tests/rust/test.sh` by removing the binary/library scaffolding tests.
- **CI**: Add `rust-bin` and `rust-lib` to the `nix-tests.yml` matrix.

## Capabilities

### New Capabilities

- `rust-bin-template`: Content and structure of the Rust binary project template at `templates/rust-bin/` (flake.nix with active `buildRustPackage` and `packages.default`, `Cargo.toml`, `src/main.rs`, `Cargo.lock`, README, `.envrc`, `.gitignore`; conventions: runtimeDeps/buildDeps/devDeps/libPath with `makeWrapper` in buildDeps). Template must pass `nix flake check`; `nix build` must produce a runnable binary; tests verify the binary runs and devShells work.
- `rust-lib-template`: Content and structure of the Rust library project template at `templates/rust-lib/` (flake.nix with active library package output and custom install phase, `Cargo.toml` with `[lib] crate-type`, `src/lib.rs`, `Cargo.lock`, README, `.envrc`, `.gitignore`; conventions: runtimeDeps/buildDeps/devDeps/libPath). Template must pass `nix flake check`; `nix build` must produce library files (`.so`/`.dylib`); tests verify library output exists and devShells work.

### Modified Capabilities

- `rust-template`: Remove the commented-out binary and library package output blocks from `templates/rust/flake.nix`. Update README to reference `rust-bin` and `rust-lib` templates for project scaffolding. Template remains a devShell-only Rust environment.
- `root-templates`: Add `templates.rust-bin` and `templates.rust-lib` entries to the root flake with path and description. Add test scripts (`tests/rust-bin/test.sh`, `tests/rust-lib/test.sh`) and CI matrix entries.

## Impact

- **Root**: `flake.nix` gains `templates.rust-bin` and `templates.rust-lib`; `.github/workflows/nix-tests.yml` gains matrix entries.
- **Modified**: `templates/rust/flake.nix` shrinks (commented blocks removed); `templates/rust/README.md` updated; `tests/rust/test.sh` simplified.
- **New**: `templates/rust-bin/` and `templates/rust-lib/` directories with full project scaffolds.
- **Dependencies**: Both new templates use the same inputs as `templates/rust/` (nixpkgs, flake-parts, rust-overlay). No new external dependencies.
- **Downstream**: Users can create ready-to-build Rust projects via `nix flake new -t <ref>#rust-bin <dir>` or `nix flake new -t <ref>#rust-lib <dir>`.
