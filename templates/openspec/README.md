# OpenSpec template

Nix flake template for a new project with [OpenSpec](https://github.com/Fission-AI/OpenSpec) and a devShell.

## What you get

- **flake.nix** — flake-parts flake with OpenSpec as a dev dependency
- **devShell** — `nix develop` gives you the `openspec` CLI and a minimal project layout
- **.envrc** — `direnv` + `use flake` for automatic shell activation (if you use direnv)

## After creating a project

```bash
cd <your-project-dir>
nix develop   # or: direnv allow
openspec init # initialize OpenSpec in this project
openspec new change "my-feature"   # create a new change
openspec status --change "my-feature"   # see artifact status
```

## Verify the template

From the template hub repo:

```bash
nix flake new -t path:.#openspec ./test-out
cd test-out && nix flake check
```
