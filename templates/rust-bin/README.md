# Rust binary template

Nix flake template for Rust binary projects using [rust-overlay](https://github.com/oxalica/rust-overlay) and flake-parts. Comes with a ready-to-build scaffold — `nix build` works out of the box.

## What you get

- **Cargo.toml + src/main.rs** — minimal binary crate, ready to build
- **flake.nix** — flake-parts flake with rust-overlay, `buildRustPackage`, and `packages.default`
- **devShell** — `nix develop` gives you `rustc`, `cargo`, `clippy`, `rustfmt`, and `rust-src`
- **.envrc** — `direnv` + `use flake` for automatic shell activation

## Quick start

```bash
nix flake new -t github:<owner>/nix-flake-templates#rust-bin my-project
cd my-project
nix develop   # or: direnv allow
nix build     # produces result/bin/my-project
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

The template exposes `packages.default` via `buildRustPackage`. The binary is wrapped with `wrapProgram` so that runtime libraries from `libPath` are available.

```bash
nix build              # build the binary
./result/bin/my-project  # run it
```

## Adding dependencies

Edit the dependency lists in `flake.nix`:

| List | Purpose | Examples |
|------|---------|----------|
| `runtimeDeps` | Libraries linked at runtime | `openssl`, `zlib` |
| `buildDeps` | Build-time tools | `pkg-config`, `rustPlatform.bindgenHook` |
| `devDeps` | Dev-only tools | `rust-analyzer`, `cargo-watch` |
| `libPath` | Runtime lib path (for `LD_LIBRARY_PATH` / wrappers) | Same libs as `runtimeDeps` |

After adding a runtime library (e.g. `openssl`), add it to both `runtimeDeps` and `libPath`.

## Multi-binary workspace

To build multiple binaries from a Cargo workspace:

1. Create workspace members:
   ```bash
   mkdir -p crates/cli crates/server
   cargo init crates/cli
   cargo init crates/server
   ```

2. Update the root `Cargo.toml`:
   ```toml
   [workspace]
   members = ["crates/*"]
   ```

3. In `flake.nix`, duplicate or adjust the `rustPackage` function and expose multiple package outputs:
   ```nix
   packages.cli = rustPackage "";
   packages.server = rustPackage "";
   packages.default = self'.packages.cli;
   ```

   Adjust `wrapProgram` to reference the correct binary name for each package.
