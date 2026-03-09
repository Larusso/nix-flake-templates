## Context

The repo is a personal Nix project template hub (AGENTS.md, TEMPLATE_PLAN.md). Current state: a single OpenSpec devShell at the root (flake.nix with flake-parts, openspec input, one devShell). There are no template outputs; `nix flake new -t <ref>#openspec` is not possible. Nix only allows one template path per name and does not compose templates, so we need an explicit `templates/openspec/` directory and a root flake that exposes it. Conventions: flake-parts, runtimeDeps/buildDeps/devDeps/libPath; generated projects must not expose `templates` so they remain consumers.

## Goals / Non-Goals

**Goals:**

- Enable `nix flake new -t <this-repo>#openspec <target-dir>` to produce a working OpenSpec project.
- Root flake exposes `templates.openspec` and `templates.default`, and provides a root devShell with OpenSpec for developing this repo.
- OpenSpec template at `templates/openspec/` provides the same devShell and structure as the current root (flake, .envrc, .gitignore ignoring .direnv).
- Each template has runnable tests so it is clear what the template is supposed to do: a flake check that the template builds, plus content tests that verify the flake behaviour (e.g. openspec on PATH in devShell, generated project has no `templates` output); tests run via `tests/` scripts and can be extended later (e.g. multi-system).

**Non-Goals:**

- Adding other templates (rust, rust-openspec) in this change.
- Changing the OpenSpec devShell contents (same inputs and packages).
- Supporting template composition inside Nix (we use a single copied directory per template).

## Decisions

1. **Root flake: templates + root devShell with OpenSpec**  
   - **Choice**: Root flake has `outputs.templates` (openspec, default) and a root devShell that includes the OpenSpec package (same inputs: nixpkgs, flake-parts, openspec), so we can run `nix develop` at repo root and use `openspec` to work on this repo.  
   - **Rationale**: Keeps the outer OpenSpec setup for developing the template hub (creating changes, running openspec CLI) without having to `cd templates/openspec` to get a shell.

2. **Template content: move current flake, .envrc, .gitignore**  
   - **Choice**: Copy current root `flake.nix`, `.envrc`, and `.gitignore` (which ignores `.direnv`) into `templates/openspec/` unchanged (aside from any path references).  
   - **Rationale**: No behavior change for the generated project; it gets the same flake, direnv setup, and basic gitignore so `.direnv` is not committed.  
   - **Alternative**: Simplify the template flake (e.g. drop flake-parts) — rejected to keep convention and future flexibility.

3. **Root .envrc and flake.lock**  
   - **Choice**: Keep root `.envrc` as `use flake` and keep `flake.lock` so the repo can be developed at root with a stable lockfile and the root devShell (OpenSpec available).  
   - **Rationale**: We want to develop the hub at repo root with OpenSpec; `.envrc` and lockfile support that.

4. **Template tests: flake check + content tests + tests/ scripts**  
   - **Choice**: Each template’s flake exposes a `checks` output (e.g. `checks.devShell-builds` = devShell) so `nix flake check ./templates/<name>` verifies the template builds. The same script runs **content tests**: for the OpenSpec template, run `nix flake new -t path:repo#openspec <temp-dir>` (the real user workflow), then `nix develop -c openspec --version` to verify openspec is on PATH, and assert the generated project flake does not expose `templates`. A `tests/` directory at repo root contains one script per template and `tests/check-all-templates.sh`; `tests/README.md` documents how to run tests and how to add tests for new templates. Content tests can be skipped with `SKIP_CONTENT_TESTS=1` for a faster build-only run.  
   - **Rationale**: Build check is repeatable and declarative; content tests encode the same checks done during manual verify (openspec in PATH, no templates in output) so the spec is testable; scripts give a single entry point; design can be extended later (e.g. multi-system, full `nix flake new` in content test) without changing the structure.  
   - **Alternative**: Root flake `checks` that run template checks inside a derivation (e.g. with `pkgs.nix`) — deferred to avoid sandbox/network and optional nix-in-nix; script-based run is sufficient and easy to extend.

## Risks / Trade-offs

- **Risk**: Users expect `nix flake new -t .#openspec out` to give a devShell at the root of `out`; the template is a single directory, so the copied content is exactly what we put in `templates/openspec/`.  
  **Mitigation**: Document that the generated project has one flake at its root; no extra nesting.

- **Risk**: Root flake must provide both templates and a devShell; duplication of OpenSpec input and devShell logic between root and template.  
  **Mitigation**: Root flake uses the same inputs and a single devShell definition (OpenSpec in buildInputs/devDeps); template is a copy of the prior standalone flake. Accept minor duplication between root and `templates/openspec/flake.nix`.

## Migration Plan

1. Create `templates/openspec/`.
2. Copy current `flake.nix`, `.envrc`, and `.gitignore` into `templates/openspec/`.
3. Replace root `flake.nix` with template-hub flake: same inputs, `outputs.templates` (openspec, default) and `outputs.devShells.default` with OpenSpec for repo development.
4. Keep root `flake.lock` and `.envrc` so `nix develop` at repo root loads the root devShell with OpenSpec.
5. Add template tests: in each template flake, add a `checks` output (e.g. devShell-builds); add `tests/` with `check-openspec-template.sh` (flake check + content tests: openspec in PATH, no templates in template flake), `check-all-templates.sh`, and `README.md`.
6. Verify: run `./tests/check-openspec-template.sh` and confirm build and content tests pass.

Rollback: Revert root flake to current content, remove `templates/openspec/` if desired.

## Open Questions

- None for this change.
