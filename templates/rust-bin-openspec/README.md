# Rust binary + OpenSpec template

Nix flake template for Rust binary projects with [rust-overlay](https://github.com/oxalica/rust-overlay) and [OpenSpec](https://github.com/Fission-AI/OpenSpec) in the same development environment. The project scaffold is ready to build and keeps the OpenSpec CLI available for spec work.

## What you get

- `Cargo.toml`, `Cargo.lock`, and `src/main.rs` for a minimal binary crate
- `flake.nix` with flake-parts, rust-overlay, OpenSpec, `buildRustPackage`, and `packages.default`
- `devShells.stable` and `devShells.nightly` with `rustc`, `cargo`, and `openspec`
- `.envrc` and `.gitignore`

## Quick start

```bash
nix flake new -t github:<owner>/nix-flake-templates#rust-bin-openspec my-project
cd my-project
nix develop
openspec init
nix build
./result/bin/my-project
```

## OpenSpec workflow

Use the same shell for implementation and spec work:

```bash
openspec new change "add-feature"
openspec status --change "add-feature"
```

## Extending the binary project

- Add runtime libraries to both `runtimeDeps` and `libPath`
- Add build-time tools such as `pkg-config` to `buildDeps`
- Add developer-only tools such as `rust-analyzer` or `cargo-watch` to `devDeps`
- For multiple binaries, expose additional package outputs in `flake.nix`

## MSRV

The template includes a commented MSRV block. To use it, add `rust-version` to `Cargo.toml` and uncomment the `msrv` lines in `flake.nix`.
