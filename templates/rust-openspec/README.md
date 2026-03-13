# Rust + OpenSpec template

Nix flake template for Rust development with [rust-overlay](https://github.com/oxalica/rust-overlay) and [OpenSpec](https://github.com/Fission-AI/OpenSpec) in the same devShell. This is a devShell-first template: it gives you Rust tooling and the OpenSpec CLI without forcing a crate layout up front.

## What you get

- `flake.nix` with flake-parts, rust-overlay, OpenSpec, and the shared `runtimeDeps` / `buildDeps` / `devDeps` / `libPath` layout
- `devShells.stable` and `devShells.nightly` with `rustc`, `cargo`, and `openspec`
- `.envrc` for direnv + `use flake`
- `.gitignore` that ignores `.direnv`

## Quick start

```bash
nix flake new -t github:<owner>/nix-flake-templates#rust-openspec my-project
cd my-project
nix develop
```

## Common next steps

Initialize OpenSpec in the generated project:

```bash
openspec init
openspec new change "my-first-change"
```

Start a binary crate:

```bash
cargo init --bin .
```

Start a library crate:

```bash
cargo init --lib .
```

Start a workspace:

```bash
mkdir crates
cargo init --bin crates/app
cat > Cargo.toml <<'EOF'
[workspace]
members = ["crates/*"]
EOF
```

If you want a ready-to-build crate scaffold immediately, use `rust-bin-openspec` or `rust-lib-openspec` instead.

## Adding dependencies

Edit the dependency lists in `flake.nix`:

- `runtimeDeps`: runtime libraries such as `openssl` or `zlib`
- `buildDeps`: build-time tools such as `pkg-config`, `rustPlatform.bindgenHook`, or `makeWrapper`
- `devDeps`: development tools such as `rust-analyzer`, `cargo-watch`, or additional CLIs
- `libPath`: the runtime library path, usually mirroring `runtimeDeps`
