# Personal Nix project template hub

This repo is a **personal Nix project template hub**: a collection of Nix flake templates for bootstrapping new projects (OpenSpec, and later Rust, rust-openspec, etc.).

## Mission

Provide reusable Nix flake templates so new projects can be created with `nix flake new -t <this-repo>#<template-name> <target-dir>` and get a consistent devShell and structure.

## Current state

- The root flake is currently a single **OpenSpec** devShell (no template outputs yet).
- A multi-template layout (thin root flake + `templates/<name>/` directories) is planned; see [TEMPLATE_PLAN.md](TEMPLATE_PLAN.md) for the strategy and combination approach (e.g. rust-openspec).

## Conventions

- Use **flake-parts** for the flake structure.
- In each template’s flake, keep the **runtimeDeps** / **buildDeps** / **devDeps** / **libPath** pattern for clarity (see **Template flake base pattern** below).
- Templates produce normal project flakes: the generated project must **not** expose a `templates` output (so it stays a consumer, not a template hub).
- Every template MUST include a **README.md** that explains what the template provides, how to get started after creating a project, and any setup steps specific to the template's language/toolchain (e.g. for Rust: how to set up a binary crate, library crate, multi-binary workspace, or mixed crate).

### Template flake base pattern

Every template flake MUST use this dependency and shell layout so projects stay consistent and agents don't need to re-specify it per template:

- **runtimeDeps** — List of derivations needed at **runtime** (e.g. OpenSSL, libs). Passed to the devShell as `buildInputs` and, when building a binary, to `buildRustPackage.buildInputs`. Use for libraries the compiled binary or tools will link against.
- **buildDeps** — List of derivations needed only at **build time** (e.g. `pkg-config`, `rustPlatform.bindgenHook`, `makeWrapper`). Passed as `nativeBuildInputs` (together with devDeps) so they are available in the devShell and to the build.
- **devDeps** — List of derivations used only in **development** (e.g. OpenSpec, rust-analyzer, linters). Passed as `nativeBuildInputs` alongside buildDeps so they are in the devShell but not required for a minimal build.
- **libPath** — `lib.makeLibraryPath [ ... ]` of runtime libraries (typically the same as or a subset of runtimeDeps). Set in the devShell (e.g. `LD_LIBRARY_PATH`) and in `postInstall`/wrapper scripts when building binaries, so that runtime linking works.

DevShell construction: `buildInputs = runtimeDeps; nativeBuildInputs = buildDeps ++ devDeps ++ [ ... toolchain or other shell-only deps ];` and expose `libPath` in the environment when relevant. When defining `buildRustPackage`, use `buildInputs = runtimeDeps`, `nativeBuildInputs = buildDeps`, and in `postInstall` use `libPath` for any `wrapProgram`/`LD_LIBRARY_PATH` so the installed binary finds the same runtime libs as the devShell.

## Reference

Multi-template layout, combination templates, and implementation steps: [TEMPLATE_PLAN.md](TEMPLATE_PLAN.md).
