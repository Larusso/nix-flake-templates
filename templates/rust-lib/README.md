# Rust library template

Nix flake template for Rust library projects using [rust-overlay](https://github.com/oxalica/rust-overlay) and flake-parts. Comes with a ready-to-build scaffold — `nix build` produces a shared library out of the box.

## What you get

- **Cargo.toml + src/lib.rs** — minimal library crate with `crate-type = ["cdylib"]`
- **flake.nix** — flake-parts flake with rust-overlay, `buildRustPackage`, and `packages.default` producing a `.so` / `.dylib`
- **devShell** — `nix develop` gives you `rustc`, `cargo`, `clippy`, `rustfmt`, and `rust-src`
- **.envrc** — `direnv` + `use flake` for automatic shell activation

## Quick start

```bash
nix flake new -t github:<owner>/nix-flake-templates#rust-lib my-lib
cd my-lib
nix develop   # or: direnv allow
nix build     # produces result/lib/libmy_lib.dylib (or .so on Linux)
```

## DevShells

| Shell | Command | Toolchain |
|-------|---------|-----------|
| stable (default) | `nix develop` | Latest stable |
| nightly | `nix develop .#nightly` | Latest nightly |
| msrv | `nix develop .#msrv` | Minimum supported Rust version |

To enable the **msrv** shell, add `rust-version` to your `Cargo.toml` and uncomment the msrv lines in `flake.nix`:

```toml
[package]
rust-version = "1.80.0"
```

## Building

The template exposes `packages.default` via `buildRustPackage` with a custom install phase that copies the built library to `$out/lib/`.

```bash
nix build          # build the library
ls result/lib/     # libmy_lib.dylib (macOS) or libmy_lib.so (Linux)
```

## Crate type options

The default `crate-type` is `["cdylib"]` (C-compatible dynamic library). You can change this in `Cargo.toml`:

| Type | Output | Use case |
|------|--------|----------|
| `cdylib` | `.so` / `.dylib` | Shared library loadable by C/Python/other languages |
| `staticlib` | `.a` | Static library for linking into C/C++ projects |
| `rlib` | `.rlib` | Rust-only library (default if `[lib]` section is omitted) |

For `staticlib`, update `Cargo.toml`:

```toml
[lib]
crate-type = ["staticlib"]
```

The `installPhase` in `flake.nix` already copies `.a` files alongside `.so` / `.dylib`.

## Adding dependencies

Edit the dependency lists in `flake.nix`:

| List | Purpose | Examples |
|------|---------|----------|
| `runtimeDeps` | Libraries linked at runtime | `openssl`, `zlib` |
| `buildDeps` | Build-time tools | `pkg-config`, `rustPlatform.bindgenHook` |
| `devDeps` | Dev-only tools | `rust-analyzer`, `cargo-watch` |
| `libPath` | Runtime lib path (for `LD_LIBRARY_PATH`) | Same libs as `runtimeDeps` |
