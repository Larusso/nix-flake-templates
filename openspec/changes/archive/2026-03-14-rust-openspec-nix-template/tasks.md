## 1. Root template registration and test wiring

- [x] 1.1 Add `rust-openspec`, `rust-bin-openspec`, and `rust-lib-openspec` to the root flake `templates` output with correct paths and descriptions
- [x] 1.2 Update `tests/run-all.sh` and any related test documentation so the three new combination template test scripts run from the repo root

## 2. DevShell-only Rust + OpenSpec template

- [x] 2.1 Create `templates/rust-openspec/` by adapting the existing `rust` template flake to include OpenSpec in `devDeps` while keeping the shared dependency-list pattern and Rust shell behavior
- [x] 2.2 Add `templates/rust-openspec/README.md`, `.envrc`, `.gitignore`, and lockfile content consistent with the combined-template requirements
- [x] 2.3 Add `tests/rust-openspec/test.sh` to verify `nix flake check`, `rustc`, `cargo`, and `openspec` in the generated devShell, and absence of `templates` output

## 3. Binary Rust + OpenSpec template

- [x] 3.1 Create `templates/rust-bin-openspec/` by adapting the existing `rust-bin` template flake and scaffold to include OpenSpec in the devShell without changing the binary package behavior
- [x] 3.2 Add `templates/rust-bin-openspec/README.md`, `.envrc`, `.gitignore`, `Cargo.toml`, `Cargo.lock`, and `src/main.rs` consistent with the binary-combination requirements
- [x] 3.3 Add `tests/rust-bin-openspec/test.sh` to verify `nix flake check`, `rustc`, `cargo`, and `openspec` in the generated devShell, successful `nix build`, and absence of `templates` output

## 4. Library Rust + OpenSpec template

- [x] 4.1 Create `templates/rust-lib-openspec/` by adapting the existing `rust-lib` template flake and scaffold to include OpenSpec in the devShell without changing the library package behavior
- [x] 4.2 Add `templates/rust-lib-openspec/README.md`, `.envrc`, `.gitignore`, `Cargo.toml`, `Cargo.lock`, and `src/lib.rs` consistent with the library-combination requirements
- [x] 4.3 Add `tests/rust-lib-openspec/test.sh` to verify `nix flake check`, `rustc`, `cargo`, and `openspec` in the generated devShell, successful `nix build`, and absence of `templates` output

## 5. Final verification

- [x] 5.1 Run the three new per-template test scripts and confirm they pass
- [x] 5.2 Run the aggregate template test runner and confirm the new templates are included and passing
