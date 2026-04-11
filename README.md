# Nix flake templates and helper flakes

A small hub of Nix flake templates for bootstrapping new projects with a consistent devShell and structure, plus standalone helper flakes that are easier to keep here than in separate repositories.

## Templates

Create a new project from a template:

```bash
nix flake new -t <this-repo>#<template-name> <target-dir>
```

Examples:

- From this repo (local path):
  ```bash
  nix flake new -t path:.#openspec ./my-openspec-project
  ```
- From GitHub (once pushed):
  ```bash
  nix flake new -t github:Larusso/nix-flake-templates#openspec ./my-openspec-project
  ```

| Template | Description |
|---|---|
| `openspec` / `default` | OpenSpec project with Nix devShell |
| `rust` | Rust devShell (stable, nightly, msrv) without a build output |
| `rust-bin` | Rust binary project where `nix build` produces a runnable binary |
| `rust-lib` | Rust library project where `nix build` produces a shared library |

See [TEMPLATE_PLAN.md](TEMPLATE_PLAN.md) for combination templates such as `rust-openspec`.

## Helper Flakes

Helper flakes live under `flakes/` as independent flakes. For easier installation, the root flake also re-exports selected install-oriented packages.

| Helper flake | Root package attrs | Description |
|---|---|---|
| `flakes/oh-my-cloudecode` | `.#oh-my-cloudecode`, `.#oh-my-cloudecode-files` | Packaging flake for the `oh-my-claudecode` upstream under the hosted name `oh-my-cloudecode` |
| `flakes/oh-my-codex` | `.#oh-my-codex`, `.#oh-my-codex-files` | Packaging flake for the `oh-my-codex` upstream |

Examples:

```bash
# Build the main packaged helper
nix build .#oh-my-cloudecode

# Build files-only helper assets
nix build .#oh-my-codex-files

# Use a helper flake directly
nix build ./flakes/oh-my-codex#default
```

## Develop this repo

```bash
nix develop
```

Then run `./tests/run-all.sh` (or `./tests/openspec/test.sh` for the OpenSpec template only) to verify templates. CI runs these tests on push and PR (Linux, matrix per template); a scheduled workflow keeps template flake locks up to date.

Helper flakes remain directly usable from `./flakes/<name>`, and selected helper packages are forwarded through the root flake as convenience package attrs.

## Reference

- [AGENTS.md](AGENTS.md) — conventions and current state
- [TEMPLATE_PLAN.md](TEMPLATE_PLAN.md) — multi-template layout and combination strategy
- `flakes/README.md` — helper-flake directory purpose
