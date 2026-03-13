# Nix flake templates

A small hub of Nix flake templates for bootstrapping new projects with a consistent devShell and structure.

## Usage

Create a new project from a template:

```bash
nix flake new -t <this-repo>#<template-name> <target-dir>
```

**Examples:**

- From this repo (local path):
  ```bash
  nix flake new -t path:.#openspec ./my-openspec-project
  ```
- From GitHub (once pushed):
  ```bash
  nix flake new -t github:Larusso/nix-flake-templates#openspec ./my-openspec-project
  ```

## Templates

| Template   | Description                          |
|-----------|--------------------------------------|
| `openspec` / `default` | OpenSpec project with Nix devShell |
| `rust` | Rust devShell (stable, nightly, msrv) — no build output |
| `rust-bin` | Rust binary project — `nix build` produces a runnable binary |
| `rust-lib` | Rust library project — `nix build` produces a shared library |

See [TEMPLATE_PLAN.md](TEMPLATE_PLAN.md) for combination templates (e.g. rust-openspec).

## Develop this repo

```bash
nix develop
```

Then run `./tests/run-all.sh` (or `./tests/openspec/test.sh` for the OpenSpec template only) to verify templates. CI runs these tests on push and PR (Linux, matrix per template); a scheduled workflow keeps template flake locks up to date.

## Reference

- [AGENTS.md](AGENTS.md) — conventions and current state
- [TEMPLATE_PLAN.md](TEMPLATE_PLAN.md) — multi-template layout and combination strategy
