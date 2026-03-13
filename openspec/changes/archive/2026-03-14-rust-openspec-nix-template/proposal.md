## Why

Projects that use both Rust and OpenSpec (e.g. Rust codebases that adopt OpenSpec for specs and changes) need combined templates for the three Rust entry points already supported by this repo: a devShell-only Rust template, a binary crate template, and a library crate template. Nix cannot merge two templates in one `nix flake new`; the only way is a dedicated combination template per project shape, as in TEMPLATE_PLAN.md.

## What Changes

- Add **templates/rust-openspec/** as the devShell-only Rust+OpenSpec combination template.
- Add **templates/rust-bin-openspec/** as the binary-crate Rust+OpenSpec combination template.
- Add **templates/rust-lib-openspec/** as the library-crate Rust+OpenSpec combination template.
- **Root flake**: register `templates.rust-openspec`, `templates.rust-bin-openspec`, and `templates.rust-lib-openspec` with their paths and descriptions.
- **Template content**:
  - `templates/rust-openspec/`: flake.nix, README.md, `.envrc`, `.gitignore`; Rust + OpenSpec in one mkShell; generated project must not expose `templates`.
  - `templates/rust-bin-openspec/`: flake.nix, Cargo scaffold, README.md, `.envrc`, `.gitignore`; same as `rust-bin` plus OpenSpec in the devShell.
  - `templates/rust-lib-openspec/`: flake.nix, Cargo scaffold, README.md, `.envrc`, `.gitignore`; same as `rust-lib` plus OpenSpec in the devShell.
- **Tests**: extend `tests/` to run build and content checks for all three combination templates (Rust toolchain and OpenSpec on PATH, no `templates` output; build checks for bin/lib variants).

## Capabilities

### New Capabilities

- `rust-openspec-template`: Content and structure of the Rust+OpenSpec devShell template at `templates/rust-openspec/` (flake.nix with Rust toolchain and OpenSpec in the same devShell, README.md, `.envrc`, `.gitignore`; conventions: runtimeDeps/buildDeps/devDeps/libPath). Template must pass `nix flake check`; tests verify `rustc`, `cargo`, and `openspec` on PATH and that the generated project does not expose `templates`.
- `rust-bin-openspec-template`: Content and structure of the Rust binary + OpenSpec template at `templates/rust-bin-openspec/` (binary Cargo scaffold plus flake.nix with `rust-bin` behavior and OpenSpec in devShell). Template must pass `nix flake check`; tests verify `rustc`, `cargo`, and `openspec` on PATH, that `nix build` produces a runnable binary, and that the generated project does not expose `templates`.
- `rust-lib-openspec-template`: Content and structure of the Rust library + OpenSpec template at `templates/rust-lib-openspec/` (library Cargo scaffold plus flake.nix with `rust-lib` behavior and OpenSpec in devShell). Template must pass `nix flake check`; tests verify `rustc`, `cargo`, and `openspec` on PATH, that `nix build` produces a library artifact, and that the generated project does not expose `templates`.

### Modified Capabilities

- `root-templates`: Add `templates.rust-openspec`, `templates.rust-bin-openspec`, and `templates.rust-lib-openspec` (paths and descriptions); add test scripts/steps for the three combination templates in `tests/`.

## Impact

- **Root**: `flake.nix` gains `templates.rust-openspec`, `templates.rust-bin-openspec`, and `templates.rust-lib-openspec`; `tests/` gains checks for all three combination templates.
- **New**: `templates/rust-openspec/`, `templates/rust-bin-openspec/`, and `templates/rust-lib-openspec/`.
- **Dependencies**: Same OpenSpec input as the OpenSpec template; Rust toolchain and package behavior follow the existing `rust`, `rust-bin`, and `rust-lib` templates respectively.
- **Downstream**: Users can create Rust+OpenSpec Nix projects via `nix flake new -t <ref>#rust-openspec <dir>`, `#rust-bin-openspec`, or `#rust-lib-openspec`.
