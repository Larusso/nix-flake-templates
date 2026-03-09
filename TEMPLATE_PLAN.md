# Multi-template flake and combination strategy (for later)

Plan for when you add multiple templates. Current repo is OpenSpec-only; template building starts with the openspec template.

## How Nix templates work (no built-in composition)

`nix flake new -t <ref>#<name>` copies **one** directory from `templates.<name>.path`. There is no way to "merge" two templates in one command. So:

- **Single-language templates**: one directory each (e.g. `openspec`, `rust`).
- **Combinations**: each combo is its own template (e.g. `rust-openspec`) with its own directory. You maintain those explicitly; Nix does not combine two templates automatically.

Usage after restructure:

- `nix flake new -t github:you/open_spec_template#openspec my-project`
- `nix flake new -t github:you/open_spec_template#rust-openspec my-rust-spec-project`

## Target layout

```
open_spec_template/
  flake.nix              # Thin: only inputs + outputs.templates.* (no devShells)
  flake.lock
  .envrc                 # Optional: "use flake" if you want to develop this repo
  templates/
    openspec/            # Current project → becomes this template
      flake.nix          # Current flake content (devShells, openspec, runtimeDeps, etc.)
      .envrc
    rust/                # Optional: plain Rust template (no OpenSpec)
      flake.nix
      .envrc
    rust-openspec/       # Explicit combination: Rust + OpenSpec
      flake.nix          # Both rust toolchain and openspec in devShell
      .envrc
```

- **Root flake.nix**  
  - Keep only `inputs` needed to evaluate the flake. Root can be minimal: `outputs = { templates = { openspec = { path = ./templates/openspec; description = "..." }; default = ... }; };` and no `perSystem`/devShells unless you want a devShell for editing this repo.
- **templates/openspec/**  
  - Move the current flake.nix (and .envrc) here. This is the "openspec" template; the flake here must not define `outputs.templates` so the new project is a normal project.
- **templates/rust/** (optional)  
  - New template: Rust-only devShell (e.g. rustup/cargo from nixpkgs). No OpenSpec.
- **templates/rust-openspec/**  
  - New template: one flake that pulls in both Rust and OpenSpec (e.g. same openspec input + rust toolchain in the same `mkShell`). This is the only way to get "Rust + OpenSpec" in one `nix flake new`; it's a dedicated combo template.

## Root flake.nix shape (when you add templates)

- **outputs**:  
  - `templates.openspec` → `path = ./templates/openspec`, `description = "OpenSpec project"`.  
  - `templates.default` → same as `openspec` so `nix flake new -t <ref>` (no `#`) uses openspec.  
  - Optionally `templates.rust`, `templates.rust-openspec` with their paths and descriptions.

No `perSystem` or `devShells` in the root flake unless you want a dev environment for working on this template repo.

## Implementation steps (when you do it)

1. Create `templates/openspec/` and move the current flake.nix and .envrc into it (so the existing OpenSpec devShell lives only inside the template).
2. Replace root flake.nix with a minimal flake: `outputs.templates.openspec`, `templates.default` → `./templates/openspec`, and optional `templates.rust`, `templates.rust-openspec` with `path` and `description`.
3. Add `templates/rust/` (optional): minimal Rust devShell flake + .envrc.
4. Add `templates/rust-openspec/`: one flake.nix that declares both OpenSpec and Rust, plus .envrc.
5. Keep or remove root .envrc and flake.lock depending on whether you want to `nix develop` at repo root.

After this, `nix flake new -t .#openspec ./out` and `nix flake new -t .#rust-openspec ./out-rust` will produce normal projects that are not templates themselves.
