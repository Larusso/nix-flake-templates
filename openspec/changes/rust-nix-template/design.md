# Design: Rust Nix template

## Context

The template hub has an OpenSpec template; we are adding a **Rust-only** template at `templates/rust/` so users can bootstrap with `nix flake new -t <ref>#rust <dir>`. The Rust template must follow the **template flake base pattern** (AGENTS.md: runtimeDeps, buildDeps, devDeps, libPath) and use a proven flake shape. The basis is an existing Rust flake that uses **rust-overlay** (oxalica/rust-overlay) with flake-parts, multiple devShells (stable, nightly, msrv), and optional `buildRustPackage` with `libPath` in wrappers.

Current state: no `templates/rust/` yet. Root flake will gain `templates.rust` and tests will gain a rust template check.

## Goals / Non-Goals

**Goals:**

- Ship `templates/rust/` whose flake is derived from the reference flake (rust-overlay, same dependency/shell pattern).
- Provide devShells: **stable** (default), **nightly**, and **msrv** (when `Cargo.toml` exists with `package.rust-version`).
- Use **runtimeDeps**, **buildDeps**, **devDeps**, **libPath** as in AGENTS.md; devShell: `buildInputs = runtimeDeps`, `nativeBuildInputs = buildDeps ++ devDeps ++ [ rustc ]`, and set `RUST_SRC_PATH` in shellHook.
- Support both **library crate** (output: .so / .rlib in a derivation) and **binary** (output: executable(s) with optional wrapProgram + libPath) via optional package outputs; document both in the template with comments.
- In-template **comments** in the flake showing how to add packages to `runtimeDeps`, `buildDeps`, and `devDeps` (with example package names).
- Template passes `nix flake check` (e.g. `checks.devShell-builds` or equivalent); no `templates` output.
- Root flake registers `templates.rust` and tests run the rust template build/content checks.

**Non-Goals:**

- Supporting rustup or other Rust version managers inside the shell (we use rust-overlay only).
- Defining a specific default set of runtimeDeps/buildDeps (template can start with empty or minimal lists; users add e.g. openssl, pkg-config, bindgenHook as needed).
- Implementing rust-openspec in this change (separate change).

## Decisions

### 1. Use rust-overlay (oxalica/rust-overlay) and `rust-bin`

**Decision:** Depend on `github:oxalica/rust-overlay` and use `pkgs.rust-bin.stable.latest.default`, `pkgs.rust-bin.selectLatestNightlyWith (...).default`, and `pkgs.rust-bin.stable.${msrv}.default` for the three devShells.

**Rationale:** Matches the reference flake; gives precise, reproducible toolchains and avoids pulling full rustup. nixpkgs’ Rust is an alternative but the reference and many Nix-Rust projects use rust-overlay.

**Alternatives:** nixpkgs Rust (simpler input story, less control); fenix (another overlay; we follow the reference choice).

### 2. Apply overlay via `perSystem` and `_module.args.pkgs`

**Decision:** In the template flake, use flake-parts and set `_module.args.pkgs = import inputs.nixpkgs { inherit system; overlays = [ (import inputs.rust-overlay) ]; };` so that `pkgs` in `perSystem` already has `rust-bin` and the overlay applied.

**Rationale:** Matches the reference flake; keeps overlay application in one place and avoids repeating it in every use of `pkgs`.

### 3. Shared `mkDevShell(rustc)` and three devShells

**Decision:** Define a `mkDevShell` that takes a `rustc` derivation (toolchain) and returns a shell with `buildInputs = runtimeDeps`, `nativeBuildInputs = buildDeps ++ devDeps ++ [ rustc ]`, and a shellHook that sets `RUST_SRC_PATH = ${pkgs.rustPlatform.rustLibSrc}`. Expose `devShells.stable`, `devShells.nightly`, and `devShells.msrv` (msrv only when `Cargo.toml` exists and has `package.rust-version`). Set `devShells.default = devShells.stable`.

**Rationale:** Same structure as the reference; one place to maintain deps and libPath; users can choose toolchain by selecting the appropriate devShell.

**Alternatives:** Single devShell with one toolchain (simpler but less flexible); multiple separate flake outputs per toolchain without a shared helper (duplication).

### 4. Optional package outputs (library and/or binary) and optional msrv

**Decision:** If `Cargo.toml` exists: (1) derive `msrv` from `package.rust-version` and expose `devShells.msrv`; (2) optionally expose one or more package outputs: (a) **library**: a derivation that builds the crate as a lib (output e.g. `$out/lib/libfoo.so` or .rlib) for use as a dependency or shared library; (b) **binary**: one or more derivations that build executables, with `postInstall` + `wrapProgram` and `libPath` so they find runtime libs. The template can expose e.g. `packages.default` (binary or lib depending on crate type) and/or `packages.<name>-lib`. If `Cargo.toml` does not exist, omit msrv and packages.

**Rationale:** Supports both “library crate starter” (.so/lib output) and “binary” (executable output) from one template; comments in the flake explain how to add each. Making packages optional keeps the template valid before the user adds a crate.

**Alternatives:** Always require Cargo.toml; separate rust vs rust-lib templates (see Decision 8).

### 5. Template starts with minimal dependency lists (and comments)

**Decision:** In the template flake, define `runtimeDeps`, `buildDeps`, `devDeps`, and `libPath` following AGENTS.md but start with empty or minimal lists. Add **in-template comments** (see Decision 7) showing how to add packages to each list, with example names. Document in the template README that users add deps as needed.

**Rationale:** Keeps the template generic; the reference’s concrete deps are project-specific. Comments in the flake give immediate guidance without opening AGENTS.md.

### 6. nixpkgs URL casing

**Decision:** Use `github:NixOS/nixpkgs/nixos-unstable` in the template for consistency with the existing openspec template (AGENTS.md and openspec template use that). The reference used `github:nixos/nixpkgs/nixos-unstable`; Nix accepts both; we standardize on the existing hub convention.

### 7. In-template comments for dependency lists

**Decision:** The template flake MUST include a comment block above or beside the `runtimeDeps`, `buildDeps`, and `devDeps` lists that explains how to add packages to each, with concrete examples (e.g. `openssl` for runtime, `pkg-config` / `rustPlatform.bindgenHook` for build, `rust-analyzer` for dev). Same for `libPath` (e.g. “add runtime libs here so binaries and the shell find them”). This avoids users guessing which list a dependency belongs in.

**Rationale:** The base pattern is documented in AGENTS.md but template users see only the flake; in-file guidance speeds adoption and keeps the pattern consistent.

### 8. One template for both library crate and binary (no split)

**Decision:** Use a **single** `rust` template that can serve both a library-only crate (output: .so / .rlib via a package derivation) and a binary crate (output: one or more executables, optionally wrapped with libPath). The flake includes commented or optional logic for: (1) building a **library** (e.g. `packages.<name>-lib` or `packages.default` when the crate is lib-only) whose derivation output is the built library (e.g. `$out/lib/libfoo.so` or .rlib); (2) building a **binary** (e.g. `packages.default` or named binaries) with `postInstall` + `wrapProgram` and `libPath` so the executable finds runtime libs. If the project has both lib and bin, both outputs can be exposed. No separate `rust-lib` vs `rust-bin` templates for now.

**Rationale:** One template is easier to maintain and discover; most projects are either lib or bin (or bin+lib in one crate). Comments and optional blocks in the same flake cover both; users delete or uncomment as needed. A library “starter” is just the same template with the lib output enabled and a minimal `lib.rs`. Splitting into two templates could be revisited if the single flake becomes too noisy or if we want distinct default Cargo.toml shapes (e.g. `[lib]`-only vs `[[bin]]`).

**Alternatives:** Two templates: `rust` (binary-focused) and `rust-lib` (library-focused with .so/lib output). Rejected for now to avoid template proliferation; one template with clear comments supports both.

### 9. Template README with setup guides for each crate type

**Decision:** The template MUST include a `README.md` (per AGENTS.md convention) that explains what the template provides and gives concrete setup steps for each common project shape: (1) **single binary crate** — `cargo init`, uncomment the binary package block, adjust the `wrapProgram` binary name; (2) **library crate** — `cargo init --lib`, add `crate-type = ["cdylib"]` or `["rlib"]` to `Cargo.toml`, uncomment the library package block; (3) **multi-binary workspace** — set up a Cargo workspace with multiple `[[bin]]` members, adjust package outputs per binary; (4) **mixed crate** (lib + bin) — combine both blocks, expose both `packages.default` (binary) and `packages.lib` (library). The README also covers devShell usage (stable/nightly/msrv), adding dependencies, and how to verify the flake.

**Rationale:** Users land in the generated project and see the README first; step-by-step guidance for each crate shape avoids them having to reverse-engineer the commented flake blocks. AGENTS.md now requires a README per template.

## Risks / Trade-offs

- **[Risk]** rust-overlay and nixpkgs revs can drift; lockfile and CI help. **Mitigation:** flake.lock in template; CI runs `nix flake check` and template tests.
- **[Risk]** msrv parsing from Cargo.toml can break on unusual format. **Mitigation:** Use `builtins.fromTOML` and a fallback (e.g. no msrv devShell) if `package.rust-version` is missing or invalid.
- **[Trade-off]** Optional package outputs (lib + bin) and comments increase template size. **Mitigation:** Comments are compact; lib/bin blocks can be commented out or conditional so the default is “devShells only”; users uncomment or add as needed.

## Migration Plan

- Add `templates/rust/` with flake.nix (and .envrc, .gitignore) derived from the reference flake; no `templates` output; include `checks` so `nix flake check ./templates/rust` passes. Flake MUST include the dependency-list comment block (Decision 7) and commented or optional blocks for library and binary package outputs (Decision 8).
- Update root flake: add `templates.rust` with path and description.
- Add or extend tests (e.g. `tests/rust/test.sh`) to run flake check and content checks (rustc/cargo on PATH, no `templates` in generated project); wire into `run-all.sh`.
- No rollback beyond reverting the commit; template is additive.

## Open Questions

- Whether the first version ships with package outputs (lib and/or bin) present but commented out, or only devShells and comments explaining how to add them (can be decided in tasks/specs).
- Exact list of systems for the template (currently follow openspec: `x86_64-linux`, `x86_64-darwin`, `aarch64-linux`, `aarch64-darwin`).
