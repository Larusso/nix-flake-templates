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

More templates (e.g. Rust, rust-openspec) are planned; see [TEMPLATE_PLAN.md](TEMPLATE_PLAN.md).

## Develop this repo

```bash
nix develop
```

Then run `./tests/check-openspec-template.sh` or `./tests/check-all-templates.sh` to verify templates.

## Reference

- [AGENTS.md](AGENTS.md) — conventions and current state
- [TEMPLATE_PLAN.md](TEMPLATE_PLAN.md) — multi-template layout and combination strategy
