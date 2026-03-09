## Why

The repo is currently a single OpenSpec devShell at the root with no way to use it as a Nix flake template. To bootstrap new OpenSpec projects with `nix flake new -t <this-repo>#openspec <target-dir>`, we need a proper template layout: a thin root flake that exposes `templates.openspec` (and `templates.default`) and a dedicated template directory containing the OpenSpec devShell and project structure.

## What Changes

- Add a **multi-template layout**: root flake exposes `outputs.templates` and keeps a **root devShell with OpenSpec** so we can continue developing this repo (e.g. creating changes, running `openspec`) at the repo root; current flake content moves into `templates/openspec/`.
- **Root flake**: templates (`templates.openspec`, `templates.default` → `./templates/openspec`) plus a root devShell that includes OpenSpec (same inputs: nixpkgs, flake-parts, openspec) for working on the template hub.
- **templates/openspec/**: new directory containing the existing OpenSpec devShell flake (current `flake.nix`, `.envrc`, and a basic `.gitignore` that ignores `.direnv`); this directory is what gets copied when users run `nix flake new -t ...#openspec`.
- Generated projects remain normal flakes (no `templates` output) so they stay consumers, not template hubs.
- **Template tests**: Each template has its own set of runnable checks so it is clear what the template is supposed to do. (1) **Build**: a flake check ensures the template builds (`nix flake check ./templates/<name>`). (2) **Content**: tests verify the flake content—e.g. for the OpenSpec template, that `openspec` is on PATH in the devShell and that the generated project flake does not expose `templates`. Scripts in `tests/` run both from the repo root; tests can be extended later (e.g. multi-system) without changing the plan.

## Capabilities

### New Capabilities

- `openspec-template`: Content and structure of the OpenSpec template at `templates/openspec/` (flake.nix, .envrc, .gitignore ignoring .direnv, and a `checks` output so the template can be verified with `nix flake check`; conventions like runtimeDeps/buildDeps/devDeps/libPath). Tests also verify flake content (openspec on PATH, no `templates` output).
- `root-templates`: Root flake shape: `outputs.templates.openspec`, `templates.default`, a root devShell with OpenSpec (and root .envrc) for developing this repo, and a `tests/` directory with scripts to run each template’s build and content checks (e.g. `tests/check-openspec-template.sh`, `tests/check-all-templates.sh`).

### Modified Capabilities

- (None; no existing specs.)

## Impact

- **Root**: `flake.nix` replaced with template-hub flake (templates + root devShell with OpenSpec); root `.envrc` and `flake.lock` kept so `nix develop` at repo root works for developing the hub with OpenSpec.
- **New**: `templates/openspec/` directory with current flake (including a `checks` output for build verification), .envrc, and .gitignore; `tests/` directory with per-template check scripts and a README.
- **Dependencies**: Same inputs (nixpkgs, flake-parts, openspec); no new runtime/build deps.
- **Downstream**: Users can create new OpenSpec projects via `nix flake new -t <ref>#openspec <dir>` and get a consistent devShell and structure.
