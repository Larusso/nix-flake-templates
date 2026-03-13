# Rust library + OpenSpec template

Nix flake template for Rust library projects with [rust-overlay](https://github.com/oxalica/rust-overlay) and [OpenSpec](https://github.com/Fission-AI/OpenSpec) in the same development environment. The scaffold builds a shared library and keeps the OpenSpec CLI available for spec work.

## What you get

- `Cargo.toml`, `Cargo.lock`, and `src/lib.rs` for a minimal Rust library crate
- `flake.nix` with flake-parts, rust-overlay, OpenSpec, a custom library install phase, and `packages.default`
- `devShells.stable` and `devShells.nightly` with `rustc`, `cargo`, and `openspec`
- `.envrc` and `.gitignore`

## Quick start

```bash
nix flake new -t github:<owner>/nix-flake-templates#rust-lib-openspec my-lib
cd my-lib
nix develop
openspec init
nix build
ls result/lib/
```

## OpenSpec workflow

Use the same shell for library development and spec work:

```bash
openspec new change "add-api"
openspec status --change "add-api"
```

## Library notes

The default crate type is `cdylib`. To switch to `staticlib` or another library type, update `Cargo.toml`. The install phase already copies `.so`, `.dylib`, and `.a` outputs into `result/lib/`.

## Extending the library project

- Add runtime libraries to `runtimeDeps` and `libPath`
- Add compilation helpers such as `pkg-config` to `buildDeps`
- Add developer-only tools such as `rust-analyzer` or `cargo-watch` to `devDeps`
- If you want a workspace or binary target too, extend `Cargo.toml` and the package outputs in `flake.nix`
