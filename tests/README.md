# Template tests

Each template has its own set of checks to ensure it builds and behaves as specified.

## Running tests

From the **repository root**:

- **OpenSpec template**: `./tests/check-openspec-template.sh`  
  Or build-only: `nix flake check ./templates/openspec`

To run all template tests (once you have more than one):

```bash
./tests/check-all-templates.sh
```

## What is tested

- **openspec**
  - **Build**: The template flake evaluates and its default devShell builds (`checks.devShell-builds`).
  - **Content**: `nix flake new -t path:repo#openspec <temp-dir>` is run to test the real workflow; then we verify (1) `openspec` is on PATH inside the devShell (`nix develop -c openspec --version`), and (2) the generated project flake does not expose a `templates` output (projects stay consumers).

Set `SKIP_CONTENT_TESTS=1` to run only the flake check (faster; skips `nix flake new` and `nix develop`). Content tests can be extended later (e.g. multi-system).

## Adding tests for a new template

1. In the template’s `flake.nix`, add a `checks` output (e.g. `checks.devShell-builds = devShells.default`).
2. Add `tests/check-<template-name>.sh` that runs `nix flake check ./templates/<template-name>` (and any content tests) from the repo root.
3. Extend `tests/check-all-templates.sh` to call the new script.
