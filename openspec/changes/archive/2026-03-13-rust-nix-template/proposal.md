## Why

The template hub currently offers only an OpenSpec template. Users who want a plain Rust project with a Nix devShell (cargo, rustfmt, etc.) without OpenSpec have no template. Adding a **Rust-only** Nix template lets them bootstrap with `nix flake new -t <ref>#rust <dir>` and get a reproducible Rust dev environment.

## What Changes

- Add **templates/rust/** as a new template: a flake that provides a devShell with Rust toolchain (e.g. via nixpkgs or rust-overlay) and standard dev tooling (cargo, rustfmt, clippy). No OpenSpec.
- **Root flake**: register `templates.rust` with path `./templates/rust` and description; optionally set or keep `templates.default` as desired.
- **templates/rust/**: flake.nix (flake-parts, runtimeDeps/buildDeps/devDeps/libPath pattern), .envrc, .gitignore; generated project must not expose `templates`.
- **Tests**: extend tests/ to run build and basic content checks for the rust template (e.g. rustc/cargo on PATH, no `templates` output).

## Capabilities

### New Capabilities

- `rust-template`: Content and structure of the Rust-only template at `templates/rust/` (flake.nix with Rust toolchain in devShell, .envrc, .gitignore; conventions: runtimeDeps/buildDeps/devDeps/libPath; no OpenSpec). Template must pass `nix flake check` and tests verify rustc/cargo on PATH and that generated project does not expose `templates`.

### Modified Capabilities

- `root-templates`: Add `templates.rust` entry and description; add test script/step for rust template (e.g. in run-all or a dedicated check script).

## Impact

- **Root**: flake.nix gains `templates.rust`; tests/ gains rust template checks.
- **New**: `templates/rust/` directory (flake.nix, .envrc, .gitignore).
- **Dependencies**: Root may need rust-related input (e.g. nixpkgs with rust, or rust-overlay) only if delegated to template flake; template flake will depend on nixpkgs (and optionally rust-overlay) for Rust toolchain.
- **Downstream**: Users can create Rust-only Nix projects via `nix flake new -t <ref>#rust <dir>`.
