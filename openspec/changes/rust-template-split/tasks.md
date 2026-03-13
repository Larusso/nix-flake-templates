## 1. Clean up templates/rust/ (devShell-only)

- [x] 1.1 Remove commented-out binary package output block from `templates/rust/flake.nix` (lines 64–84 and line 115)
- [x] 1.2 Remove commented-out library package output block from `templates/rust/flake.nix` (lines 86–102 and line 118)
- [x] 1.3 Update `templates/rust/README.md`: remove binary/library setup sections, add references to `rust-bin` and `rust-lib` templates
- [x] 1.4 Simplify `tests/rust/test.sh`: remove msrv scaffolding test (Cargo.toml creation + sed uncomment), keep flake check, stable/nightly devShell checks, no-templates check

## 2. Create templates/rust-bin/ scaffold

- [x] 2.1 Create `templates/rust-bin/` directory with `.envrc` (`use flake`) and `.gitignore` (`.direnv`, `target`)
- [x] 2.2 Create `templates/rust-bin/Cargo.toml` (minimal binary crate: name `my-project`, edition 2021)
- [x] 2.3 Create `templates/rust-bin/src/main.rs` (hello-world main function)
- [x] 2.4 Create `templates/rust-bin/flake.nix` with: inputs (nixpkgs, flake-parts, rust-overlay), explicit `pkgs` import with overlay in `let` block, runtimeDeps/buildDeps/devDeps/libPath with comments, `makeWrapper` in buildDeps, `cargoToml` binding (active), `rustPackage` function with `buildRustPackage` + `wrapProgram` + `libPath` (active), `mkDevShell`, stable/nightly devShells, commented msrv block, `packages.default = rustPackage ""`, `checks.devShell-builds`, `_module.args.pkgs`, no `templates` output
- [x] 2.5 Generate `templates/rust-bin/Cargo.lock` (stage files, run `nix develop` + `cargo generate-lockfile`)
- [x] 2.6 Run `nix flake check` on `templates/rust-bin/` and verify it passes
- [x] 2.7 Create `templates/rust-bin/README.md` (binary-focused: quick start, devShells, adding deps/features, multi-binary workspace pattern, msrv opt-in)

## 3. Create templates/rust-lib/ scaffold

- [x] 3.1 Create `templates/rust-lib/` directory with `.envrc` (`use flake`) and `.gitignore` (`.direnv`, `target`)
- [x] 3.2 Create `templates/rust-lib/Cargo.toml` (library crate: name `my-lib`, edition 2021, `[lib] crate-type = ["cdylib"]`)
- [x] 3.3 Create `templates/rust-lib/src/lib.rs` (minimal public function)
- [x] 3.4 Create `templates/rust-lib/flake.nix` with: same inputs and `pkgs` pattern as rust-bin, runtimeDeps/buildDeps/devDeps/libPath with comments, no `makeWrapper` in buildDeps, `cargoToml` binding (active), `rustLibPackage` with `buildRustPackage` + custom `installPhase` that copies `.so`/`.dylib` to `$out/lib/` (active), `mkDevShell`, stable/nightly devShells, commented msrv block, `packages.default = rustLibPackage`, `checks.devShell-builds`, no `templates` output
- [x] 3.5 Generate `templates/rust-lib/Cargo.lock` (stage files, run `nix develop` + `cargo generate-lockfile`)
- [x] 3.6 Run `nix flake check` on `templates/rust-lib/` and verify it passes
- [x] 3.7 Create `templates/rust-lib/README.md` (library-focused: quick start, devShells, crate-type options cdylib/staticlib/rlib, adding deps, msrv opt-in)

## 4. Root flake and CI

- [x] 4.1 Add `templates.rust-bin` to root `flake.nix` with `path = ./templates/rust-bin` and description
- [x] 4.2 Add `templates.rust-lib` to root `flake.nix` with `path = ./templates/rust-lib` and description
- [x] 4.3 Add `rust-bin` and `rust-lib` to `.github/workflows/nix-tests.yml` template matrix

## 5. Tests

- [x] 5.1 Create `tests/rust-bin/test.sh` (executable): flake check, `nix flake new`, stable devShell (rustc + cargo on PATH), nightly devShell, `nix build` produces binary, binary runs, msrv test (uncomment msrv lines since Cargo.toml already exists, add `rust-version`), no-templates check
- [x] 5.2 Create `tests/rust-lib/test.sh` (executable): flake check, `nix flake new`, stable devShell (rustc + cargo on PATH), nightly devShell, `nix build` produces library file (`.so` or `.dylib` in `result/lib/`), no-templates check
- [x] 5.3 Update `tests/README.md` to document `rust-bin` and `rust-lib` template tests

## 6. Validation

- [x] 6.1 Run `nix flake check` on all three rust templates (`templates/rust/`, `templates/rust-bin/`, `templates/rust-lib/`)
- [x] 6.2 Run `./tests/rust/test.sh` and confirm it passes (devShell-only checks)
- [x] 6.3 Run `./tests/rust-bin/test.sh` and confirm it passes (binary builds and runs)
- [x] 6.4 Run `./tests/rust-lib/test.sh` and confirm it passes (library output exists)
- [x] 6.5 Run `./tests/run-all.sh` and confirm all template tests pass
