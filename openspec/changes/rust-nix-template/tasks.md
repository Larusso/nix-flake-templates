## 1. Template directory and scaffold

- [x] 1.1 Create `templates/rust/` directory
- [x] 1.2 Create `templates/rust/.envrc` with `use flake`
- [x] 1.3 Create `templates/rust/.gitignore` that ignores `.direnv`

## 2. Template flake.nix

- [x] 2.1 Create `templates/rust/flake.nix` with inputs: nixpkgs (`github:NixOS/nixpkgs/nixos-unstable`), flake-parts, and rust-overlay (`github:oxalica/rust-overlay`)
- [x] 2.2 Set up flake-parts `mkFlake` with `perSystem` and `_module.args.pkgs` importing nixpkgs with rust-overlay applied
- [x] 2.3 Define `runtimeDeps`, `buildDeps`, `devDeps`, and `libPath` lists (starting empty/minimal) with in-template comments explaining how to add packages (e.g. `openssl` for runtime, `pkg-config` / `rustPlatform.bindgenHook` / `makeWrapper` for build, `rust-analyzer` for dev, runtime libs in `libPath`)
- [x] 2.4 Define `mkDevShell` function that takes a `rustc` (toolchain) arg and returns `pkgs.mkShell` with `buildInputs = runtimeDeps`, `nativeBuildInputs = buildDeps ++ devDeps ++ [ rustc ]`, and shellHook setting `RUST_SRC_PATH = ${pkgs.rustPlatform.rustLibSrc}`
- [x] 2.5 Expose `devShells.stable` (using `pkgs.rust-bin.stable.latest.default`), `devShells.nightly` (using `pkgs.rust-bin.selectLatestNightlyWith (t: t.default)`), and `devShells.default = self'.devShells.stable`
- [x] 2.6 Add commented msrv devShell block: read `Cargo.toml` with `builtins.fromTOML`, extract `package.rust-version`, expose `devShells.msrv` using `pkgs.rust-bin.stable.${msrv}.default`; include comment explaining how to enable when `Cargo.toml` exists
- [x] 2.7 Add commented block for optional binary package output: `buildRustPackage` with `buildInputs = runtimeDeps`, `nativeBuildInputs = buildDeps`, `postInstall` with `wrapProgram` and `libPath`; include comment explaining how to enable and customize
- [x] 2.8 Add commented block for optional library package output: derivation producing `.so` / `.rlib` in `$out/lib/`; include comment explaining how to enable for library crates
- [x] 2.9 Expose `checks.devShell-builds` so `nix flake check ./templates/rust` passes
- [x] 2.10 Verify flake has no `templates` output (generated project is a consumer, not a hub)

## 3. Root flake updates

- [x] 3.1 Add `templates.rust` to root `flake.nix` with `path = ./templates/rust` and `description = "Rust project with Nix devShell (rust-overlay)"`

## 4. Tests

- [x] 4.1 Create `tests/rust/test.sh` (executable) that runs `nix flake check` on the rust template
- [x] 4.2 Add content tests to `tests/rust/test.sh`: `nix flake new` from `#rust`, assert `rustc` and `cargo` are on PATH in devShell, assert generated flake.nix does not contain `templates`; respect `SKIP_CONTENT_TESTS=1`
- [x] 4.3 Verify `tests/run-all.sh` picks up the new `tests/rust/test.sh` automatically (iterates `tests/*/test.sh`)
- [x] 4.4 Update `tests/README.md` to document the rust template test (`./tests/rust/test.sh`)

## 5. CI integration

- [x] 5.1 Verify `.github/workflows/nix-tests.yml` runs `./tests/run-all.sh` (which now includes rust); no changes needed if it already runs run-all
- [x] 5.2 Verify `.github/workflows/update-template-flakes.yml` updates `templates/rust/flake.lock` if it iterates template directories; add rust if needed

## 6. Validation

- [x] 6.1 Run `nix flake check ./templates/rust` locally and confirm it passes
- [x] 6.2 Run `./tests/rust/test.sh` locally and confirm all checks pass (flake check + content tests)
- [x] 6.3 Run `./tests/run-all.sh` locally and confirm all template tests pass (openspec + rust)
