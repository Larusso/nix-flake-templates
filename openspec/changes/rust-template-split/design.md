## Context

The `rust-nix-template` change delivered a single `templates/rust/` with devShells (stable, nightly) and commented-out blocks for binary and library package outputs. Testing revealed that uncommenting those blocks requires scaffolding `Cargo.toml`, `src/` files, `Cargo.lock`, adding `makeWrapper` to `buildDeps`, and multi-line uncomments — far beyond a reasonable "uncomment and go" experience.

The prior change's Design Decision 8 ("One template for both library crate and binary, no split") is reversed here. Each project type gets its own template with a complete scaffold that builds out of the box.

All three templates share the same base pattern (AGENTS.md: runtimeDeps, buildDeps, devDeps, libPath), the same inputs (nixpkgs, flake-parts, rust-overlay), and the same devShell structure (`mkDevShell`, stable/nightly, msrv as commented hint).

## Goals / Non-Goals

**Goals:**

- Split into three Rust templates: `rust` (devShell-only), `rust-bin` (binary project), `rust-lib` (library project).
- Each project template (`rust-bin`, `rust-lib`) ships with `Cargo.toml`, source files, and `Cargo.lock` so `nix build` works immediately after `nix flake new`.
- `templates/rust/` becomes a clean devShell-only template — no commented-out package blocks.
- Tests prove that `nix build` produces the expected artifact (runnable binary or library file).

**Non-Goals:**

- Changing the devShell structure (mkDevShell, toolchain selection, RUST_SRC_PATH) — these are established and stay the same.
- Adding concrete runtime/build dependencies to the new templates — they start empty/minimal like the existing `rust` template.
- Workspace (multi-crate) templates — users can adapt `rust-bin` for workspaces; a dedicated workspace template is out of scope.
- Addressing `rust-openspec` combination templates — that is a separate change.

## Decisions

### 1. Reverse Decision 8: three templates instead of one

**Decision:** Replace the single `templates/rust/` (with commented blocks) with three templates: `rust` (devShell-only), `rust-bin` (binary project), `rust-lib` (library project).

**Rationale:** Testing the commented blocks required scaffolding Cargo.toml, src files, Cargo.lock, and targeted sed edits — proving the UX is unworkable. Separate templates give each project type a ready-to-build scaffold. Three templates is manageable and each has a clear purpose.

**Alternatives:** Keep one template with better comments or a setup script. Rejected because the fundamental issue is that different project types need different files (main.rs vs lib.rs, different Cargo.toml shapes, different flake outputs).

### 2. templates/rust/ becomes devShell-only

**Decision:** Strip `templates/rust/flake.nix` of all commented binary/library blocks (lines 64–102, 114–118). Keep devShells (stable, nightly), msrv as commented hint, dependency pattern with comments, and `checks.devShell-builds`. Update README to point users to `rust-bin` and `rust-lib` for project scaffolding.

**Rationale:** The `rust` template serves a real use case: "give me a Rust shell for exploration or adding Rust to an existing project." Removing the dead commented blocks makes it clean and focused.

### 3. rust-bin template includes makeWrapper and active buildRustPackage

**Decision:** `templates/rust-bin/flake.nix` includes `makeWrapper` in `buildDeps`, an active `cargoToml` binding, an active `rustPackage` function using `buildRustPackage` with `wrapProgram` + `libPath`, and `packages.default = rustPackage ""`. Ships with `Cargo.toml` (binary crate), `src/main.rs`, and `Cargo.lock`.

**Rationale:** This is the exact pattern from the reference flake. `makeWrapper` is required for `wrapProgram`; having it in buildDeps by default avoids a confusing build failure. The scaffold means `nix build` works immediately.

### 4. rust-lib template uses custom installPhase for library output

**Decision:** `templates/rust-lib/flake.nix` uses `buildRustPackage` with a custom `installPhase` that copies the built `.so`/`.dylib` to `$out/lib/` instead of relying on `cargo install` (which only handles binaries). Ships with `Cargo.toml` (lib crate with `crate-type = ["cdylib"]`), `src/lib.rs`, and `Cargo.lock`.

**Rationale:** `buildRustPackage`'s default install phase runs `cargo install`, which fails for library-only crates. A custom `installPhase` that finds and copies the built cdylib to `$out/lib/` solves this cleanly. The template documents the crate-type and install approach.

**Alternatives:** Use `stdenv.mkDerivation` with manual cargo build. Rejected to keep consistency with the binary template's use of `buildRustPackage` (same cargoLock handling, same build hooks). Override only the install step.

### 5. msrv remains a commented hint in all templates

**Decision:** All three templates keep msrv as a commented block (`cargoToml`, `msrv`, `msrvToolchain`, `devShells.msrv`). Users opt in by uncommenting after setting `rust-version` in their `Cargo.toml`.

**Rationale:** The user chose this approach. Even though `rust-bin` and `rust-lib` include a `Cargo.toml`, the default template Cargo.toml does not set `rust-version` — adding it is a deliberate user choice.

### 6. Each template gets a focused README

**Decision:** Each template has its own `README.md` tailored to its use case: `rust` explains devShell usage and points to `rust-bin`/`rust-lib`; `rust-bin` explains binary project setup, adding features, multi-binary patterns; `rust-lib` explains library project setup, crate-type options, consuming the library.

**Rationale:** Per AGENTS.md convention, every template must include a README. Focused READMEs are more useful than a single README covering all project types with conditional instructions.

### 7. Shared flake structure across all three templates

**Decision:** All three templates use the same inputs (`nixpkgs`, `flake-parts`, `rust-overlay`), the same `perSystem` pattern with explicit `pkgs` import and overlay application in the `let` block, the same `mkDevShell` function, and the same dependency-list comments. The only differences are the package output blocks and `buildDeps` contents.

**Rationale:** Consistency across templates. Users switching between project types see the same patterns. Changes to the base pattern can be applied uniformly.

## Risks / Trade-offs

- **[Risk]** Three templates to maintain instead of one. **Mitigation:** The flake structure is identical across all three; only the package output block and scaffold files differ. Template lock updates (`update-template-flakes.yml`) already iterate `templates/*/` automatically.
- **[Risk]** `buildRustPackage` with custom `installPhase` for libraries may break on nixpkgs updates. **Mitigation:** The install phase is minimal (find + copy); CI tests verify the library output exists. If nixpkgs changes how `buildRustPackage` works, the test will catch it.
- **[Trade-off]** `rust-lib` defaults to `cdylib` crate-type. Users wanting `staticlib` or `rlib` need to adjust `Cargo.toml` and possibly the `installPhase`. **Mitigation:** README documents alternative crate-type options and what to change.
- **[Trade-off]** The `rust` template no longer documents binary/library patterns at all (defers to the other templates). Users who want both lib and bin in one project need to combine patterns from `rust-bin` and `rust-lib`. **Mitigation:** This is an advanced use case; the focused templates serve the 90% case.
