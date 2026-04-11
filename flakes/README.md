# Helper Flakes

This directory holds standalone helper flakes that are hosted in this repository but are not project templates.

- `templates/` remains the source for `nix flake new -t ...`
- `flakes/` is for independently usable helper flakes

Some helper-flake packages are also re-exported from the root flake for convenience, but each helper flake remains usable directly via its own path.
