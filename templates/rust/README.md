# Rust template

Nix flake template for Rust projects using [rust-overlay](https://github.com/oxalica/rust-overlay) and flake-parts.

## What you get

- **flake.nix** — flake-parts flake with rust-overlay, multiple devShells (stable, nightly, msrv), and optional package outputs for binaries and libraries
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

## Setting up your project

### Single binary crate

1. Initialize the crate:
   ```bash
   cargo init .
   ```

2. In `flake.nix`, uncomment the **MSRV** block and the **binary package output** block.

3. Adjust the `wrapProgram` line if your binary name differs from the package name.

4. Add runtime libraries (e.g. `openssl`) to `runtimeDeps` and `libPath`, build tools (e.g. `pkg-config`, `makeWrapper`) to `buildDeps`.

5. Build:
   ```bash
   nix build   # produces result/bin/<your-binary>
   ```

### Library crate

1. Initialize as a library:
   ```bash
   cargo init --lib .
   ```

2. If you want a shared library (`.so` / `.dylib`), add to `Cargo.toml`:
   ```toml
   [lib]
   crate-type = ["cdylib"]
   ```
   For a Rust-only library (`.rlib`), use `crate-type = ["rlib"]` or omit (default).

3. In `flake.nix`, uncomment the **MSRV** block and the **library package output** block.

4. Build:
   ```bash
   nix build .#lib   # produces result/lib/lib<name>.so (or .dylib on macOS)
   ```

### Multi-binary workspace

1. Create a Cargo workspace:
   ```bash
   mkdir -p crates/cli crates/server
   cargo init crates/cli
   cargo init crates/server
   ```

2. Create a root `Cargo.toml`:
   ```toml
   [workspace]
   members = ["crates/*"]
   ```

3. In `flake.nix`, uncomment the **binary package output** block and duplicate it for each binary, adjusting `name` and the `wrapProgram` binary path. For example:
   ```nix
   packages.cli = rustPackage "cli" "";
   packages.server = rustPackage "server" "";
   packages.default = self'.packages.cli;
   ```
   You'll also need to adjust `rustPackage` to accept the binary name and pass it through.

### Mixed crate (library + binary)

1. Set up a crate with both `[lib]` and `[[bin]]` in `Cargo.toml`:
   ```toml
   [lib]
   crate-type = ["cdylib"]

   [[bin]]
   name = "my-tool"
   path = "src/main.rs"
   ```

2. In `flake.nix`, uncomment **both** the binary and library package output blocks.

3. Expose both:
   ```nix
   packages.default = rustPackage "";      # binary
   packages.lib = rustLibPackage;          # library
   ```

4. Build:
   ```bash
   nix build            # binary
   nix build .#lib      # library
   ```

## Adding dependencies

Edit the dependency lists in `flake.nix`:

| List | Purpose | Examples |
|------|---------|----------|
| `runtimeDeps` | Libraries linked at runtime | `openssl`, `zlib`, `p7zip` |
| `buildDeps` | Build-time tools | `pkg-config`, `rustPlatform.bindgenHook`, `makeWrapper` |
| `devDeps` | Dev-only tools | `rust-analyzer`, `cargo-watch`, `cargo-edit` |
| `libPath` | Runtime lib path (for `LD_LIBRARY_PATH` / wrappers) | Same libs as `runtimeDeps` |

After adding a runtime library (e.g. `openssl`), remember to also add it to `libPath` so that binaries and the devShell can find it.

## Verify the template

From the template hub repo:

```bash
nix flake new -t path:.#rust ./test-out
cd test-out && nix flake check
```
