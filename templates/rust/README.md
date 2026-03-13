# Rust template

Nix flake template for Rust development using [rust-overlay](https://github.com/oxalica/rust-overlay) and flake-parts. This is a **devShell-only** template — it gives you a Rust toolchain without any project scaffold.

For a ready-to-build project, use one of the project templates instead:

- **`rust-bin`** — Rust binary project with `Cargo.toml`, `src/main.rs`, and `nix build` producing a runnable binary
- **`rust-lib`** — Rust library project with `Cargo.toml`, `src/lib.rs`, and `nix build` producing a shared library (`.so` / `.dylib`)

## What you get

- **flake.nix** — flake-parts flake with rust-overlay, multiple devShells (stable, nightly), and the base dependency pattern (runtimeDeps, buildDeps, devDeps, libPath)
- **devShell** — `nix develop` gives you `rustc`, `cargo`, `clippy`, `rustfmt`, and `rust-src` (for rust-analyzer)
- **.envrc** — `direnv` + `use flake` for automatic shell activation

## Quick start

```bash
nix flake new -t github:<owner>/nix-flake-templates#rust my-project
cd my-project
nix develop   # or: direnv allow
```

## DevShells

| Shell | Command | Toolchain |
|-------|---------|-----------|
| stable (default) | `nix develop` | Latest stable |
| nightly | `nix develop .#nightly` | Latest nightly |
| msrv | `nix develop .#msrv` | Minimum supported Rust version (from `Cargo.toml`) |

The **msrv** shell requires uncommenting the msrv block in `flake.nix` and having a `Cargo.toml` with `package.rust-version` set.

## When to use this template

- Adding Rust tooling to an existing project
- Exploring Rust without committing to a project structure
- Creating a custom project layout where `rust-bin` or `rust-lib` don't fit

For most new Rust projects, start with `rust-bin` or `rust-lib` instead.

## Adding dependencies

Edit the dependency lists in `flake.nix`:

| List | Purpose | Examples |
|------|---------|----------|
| `runtimeDeps` | Libraries linked at runtime | `openssl`, `zlib`, `p7zip` |
| `buildDeps` | Build-time tools | `pkg-config`, `rustPlatform.bindgenHook`, `makeWrapper` |
| `devDeps` | Dev-only tools | `rust-analyzer`, `cargo-watch`, `cargo-edit` |
| `libPath` | Runtime lib path (for `LD_LIBRARY_PATH` / wrappers) | Same libs as `runtimeDeps` |

## Verify the template

From the template hub repo:

```bash
nix flake new -t path:.#rust ./test-out
cd test-out && nix flake check
```
