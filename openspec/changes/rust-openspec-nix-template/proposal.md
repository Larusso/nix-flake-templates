## Why

Projects that use both Rust and OpenSpec (e.g. Rust codebases that adopt OpenSpec for specs and changes) need one template that provides both: a Rust toolchain and OpenSpec in the same devShell. Nix cannot merge two templates in one `nix flake new`; the only way is a dedicated **rust-openspec** combination template, as in TEMPLATE_PLAN.md.

## What Changes

- Add **templates/rust-openspec/** as a combination template: one flake with both Rust toolchain and OpenSpec in the same devShell (same inputs pattern: nixpkgs, flake-parts, openspec; add Rust via nixpkgs or rust-overlay).
- **Root flake**: register `templates.rust-openspec` with path `./templates/rust-openspec` and description.
- **templates/rust-openspec/**: flake.nix (Rust + OpenSpec in one mkShell), .envrc, .gitignore; generated project must not expose `templates`. Follow runtimeDeps/buildDeps/devDeps/libPath conventions; shell hook can mention both Rust and OpenSpec.
- **Tests**: extend tests/ to run build and content checks for rust-openspec (rustc/cargo and openspec on PATH, no `templates` output).

## Capabilities

### New Capabilities

- `rust-openspec-template`: Content and structure of the Rust+OpenSpec template at `templates/rust-openspec/` (flake.nix with Rust toolchain and OpenSpec in same devShell, .envrc, .gitignore; conventions: runtimeDeps/buildDeps/devDeps/libPath). Template must pass `nix flake check`; tests verify rustc, cargo, and openspec on PATH and that generated project does not expose `templates`.

### Modified Capabilities

- `root-templates`: Add `templates.rust-openspec` (path and description); add test script/step for rust-openspec template in tests/.

## Impact

- **Root**: flake.nix gains `templates.rust-openspec`; tests/ gains rust-openspec template checks.
- **New**: `templates/rust-openspec/` directory (flake.nix, .envrc, .gitignore).
- **Dependencies**: Same openspec input as openspec template; template flake adds Rust (nixpkgs or rust-overlay).
- **Downstream**: Users can create Rust+OpenSpec Nix projects via `nix flake new -t <ref>#rust-openspec <dir>`.
